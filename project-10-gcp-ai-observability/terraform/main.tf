locals {
  monitoring_ns = "monitoring"
}

module "gke" {
  source       = "./modules/gke-autopilot"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
}

# Seed Helm repos into a pinned local cache (used by Grafana, kube-state-metrics, k8sgpt)
resource "null_resource" "helm_repos_seed" {
  provisioner "local-exec" {
    command = <<EOC
set -euo pipefail
mkdir -p "${path.module}/.helm/cache" "$(dirname "${path.module}/.helm/repositories.yaml")"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts \
  --repository-config "${path.module}/.helm/repositories.yaml" \
  --repository-cache "${path.module}/.helm/cache"
helm repo add grafana https://grafana.github.io/helm-charts \
  --repository-config "${path.module}/.helm/repositories.yaml" \
  --repository-cache "${path.module}/.helm/cache"
helm repo add k8sgpt https://charts.k8sgpt.ai \
  --repository-config "${path.module}/.helm/repositories.yaml" \
  --repository-cache "${path.module}/.helm/cache"
helm repo update \
  --repository-config "${path.module}/.helm/repositories.yaml" \
  --repository-cache "${path.module}/.helm/cache"
EOC
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata { name = local.monitoring_ns }
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin-credentials"
    namespace = local.monitoring_ns
    labels    = { "app.kubernetes.io/name" = "grafana" }
  }
  data = {
    admin-user     = "admin"
    admin-password = var.grafana_admin_password
  }
  type = "Opaque"
}

# --------------------------------------------------------------
# Minimal Prometheus via native k8s (Autopilot-safe, no host deps)
# --------------------------------------------------------------

# in main.tf, update kubernetes_config_map.prometheus_cfg data
resource "kubernetes_config_map" "prometheus_cfg" {
  metadata {
    name      = "prometheus-config"
    namespace = "monitoring"
    labels    = { app = "prometheus-server-minimal" }
  }
  data = {
    "prometheus.yml" = <<-EOT
      global:
        scrape_interval: 60s
        evaluation_interval: 60s
      rule_files:
        - /etc/prometheus/alerts.yml
      scrape_configs:
        - job_name: "kubernetes-pods"
          kubernetes_sd_configs: [{ role: pod }]
          relabel_configs:
            - action: keep
              source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
              regex: "true"
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
              action: replace
              target_label: __address__
              regex: (.+)
              replacement: $1
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
        - job_name: "kube-state-metrics"
          kubernetes_sd_configs: [{ role: endpoints }]
          relabel_configs:
            - action: keep
              source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name]
              regex: monitoring;kube-state-metrics
    EOT
    "alerts.yml" = <<-EOT
      groups:
        - name: sre-basics
          rules:
            - alert: TargetDown
              expr: up == 0
              for: 5m
              labels: { severity: page }
              annotations:
                summary: "Target down ({{ $labels.job }})"
                description: "{{ $labels.instance }} of job {{ $labels.job }} is down for 5m."

            - alert: HighPodRestarts
              expr: increase(kube_pod_container_status_restarts_total[10m]) > 3
              for: 10m
              labels: { severity: ticket }
              annotations:
                summary: "High pod restarts ({{ $labels.pod }})"
                description: "Container {{ $labels.container }} restarted >3 times in 10m."
    EOT
  }
}

resource "kubernetes_deployment" "prometheus_minimal" {
  metadata {
    name      = "prometheus-server-minimal"
    namespace = local.monitoring_ns
    labels    = { app = "prometheus-server-minimal" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "prometheus-server-minimal" } }
    strategy { type = "Recreate" }

    template {
      metadata { labels = { app = "prometheus-server-minimal" } }
      spec {
        container {
          name  = "prometheus"
          image = "quay.io/prometheus/prometheus:v2.54.1"

          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/data",
            "--storage.tsdb.retention.time=12h",
            "--web.enable-lifecycle"
          ]

          port {
            name           = "http"
            container_port = 9090
          }

          resources {
            requests = { cpu = "20m", memory = "128Mi" }
            limits   = { cpu = "50m", memory = "256Mi" }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9090
            }
            initial_delay_seconds = 120
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 12
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }
            initial_delay_seconds = 90
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 30
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/prometheus"
            read_only  = true
          }
          volume_mount {
            name       = "storage"
            mount_path = "/data"
          }

          security_context {
            run_as_non_root = true
            run_as_user     = 65534
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prometheus_cfg.metadata[0].name
          }
        }

        volume {
          name = "storage"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_config_map.prometheus_cfg
  ]
}

resource "kubernetes_service" "prometheus_svc" {
  metadata {
    name      = "prometheus-server"
    namespace = local.monitoring_ns
    labels    = { app = "prometheus-server-minimal" }
  }
  spec {
    type     = "ClusterIP"
    selector = { app = "prometheus-server-minimal" }
    port {
      name        = "http"
      port        = 80
      target_port = 9090
    }
  }
  depends_on = [kubernetes_deployment.prometheus_minimal]
}

# -----------------------------
# Grafana (Helm, conservative)
# -----------------------------
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.10"
  namespace  = local.monitoring_ns

  values = [file("${path.module}/values/grafana.values.yaml")]

  atomic       = true
  replace      = true
  force_update = true
  wait         = true
  timeout      = 900
  max_history  = 2

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_secret.grafana_admin,
    null_resource.helm_repos_seed
  ]
}

# -----------------------------
# kube-state-metrics (Helm slim)
# -----------------------------
resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "5.23.0"
  namespace  = local.monitoring_ns

  values = [<<EOT
resources:
  requests:
    cpu: 20m
    memory: 64Mi
  limits:
    cpu: 100m
    memory: 128Mi
EOT
  ]

  wait = true

  depends_on = [
    null_resource.helm_repos_seed,
    module.gke,
    kubernetes_namespace.monitoring
  ]
}

# -------------------
# k8sgpt-operator Helm
# -------------------
resource "helm_release" "k8sgpt_operator" {
  name             = "k8sgpt-operator"
  repository       = "https://charts.k8sgpt.ai"
  chart            = "k8sgpt-operator"
  version          = "0.2.22"
  namespace        = "k8sgpt-operator"
  create_namespace = true

  values = [file("${path.module}/values/k8sgpt-operator.values.yaml")]
  wait   = true

  depends_on = [
    null_resource.helm_repos_seed,
    module.gke,
    kubernetes_service.prometheus_svc
  ]
}

# --- RBAC for Prometheus SD (pods/services/endpoints) ---

resource "kubernetes_service_account" "prometheus_sa" {
  metadata {
    name      = "prometheus"
    namespace = local.monitoring_ns
    labels = {
      app = "prometheus-server-minimal"
    }
  }
}

resource "kubernetes_cluster_role" "prometheus_sd" {
  metadata {
    name = "prometheus-sd"
    labels = {
      app = "prometheus-server-minimal"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "pods", "services", "endpoints", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  # EndpointsSlice is used in newer clusters
  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "prometheus_sd" {
  metadata {
    name = "prometheus-sd"
    labels = {
      app = "prometheus-server-minimal"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus_sd.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus_sa.metadata[0].name
    namespace = local.monitoring_ns
  }
}

# --- ensure Prometheus Deployment uses the SA ---

