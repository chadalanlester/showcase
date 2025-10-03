# showcase/project-10-gcp-ai-observability/terraform/outputs.tf
output "cluster_name" { value = var.cluster_name }
output "region" { value = var.region }
output "endpoint" { value = module.gke.endpoint }
output "grafana_port_forward_hint" {
  value = "kubectl -n monitoring port-forward svc/kube-prom-stack-grafana 3000:80"
}
