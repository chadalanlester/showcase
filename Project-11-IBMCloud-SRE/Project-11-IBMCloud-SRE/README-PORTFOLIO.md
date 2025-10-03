# Project 6 — Azure AKS GitOps (Portfolio-Ready Section)

> Production-style AKS on free-tier constraints. GitOps-ready, observable, and auditable.

## Overview
- **Cluster**: AKS (`p6-aks`) with 1 system pool (`B2ms`) and 1 user pool (`B2ms x1`)
- **GitOps mode**: Helm-based deploys (Flux optional, off in `eastus2`)
- **Monitoring**: kube-prometheus-stack (Prometheus, Alertmanager, Grafana)
- **Secrets**: Azure Key Vault CSI + Workload Identity ready (stubs)
- **Governance**: Azure Policy add-on enabled; Terraform-managed infra
- **CI**: GitHub Actions workflow `project-6-aks-infra` (PLAN/APPLY)

---

## Architecture

```mermaid
flowchart LR
  Dev[GitHub Actions\np6-aks-infra] -->|Terraform| AKS[(AKS Cluster)]
  Dev -->|Helm| NSMON[(Namespace: monitoring)]

  subgraph Azure
    ACR[(Azure Container Registry)]
    KV[(Key Vault)]
    LAW[(Log Analytics)]
    AKS
    subgraph AKS Cluster
      SYS[(Nodepool: system\nB2ms x1 • tainted)]
      WORK[(Nodepool: work\nB2ms x1 • workloads)]
      NSMON
      GRAF[Grafana\nLoadBalancer]
      PROM[Prometheus]
      ALERT[Alertmanager]
    end
  end

  ACR --> AKS
  KV --> AKS
  LAW --> AKS
  NSMON --> GRAF
  NSMON --> PROM
  NSMON --> ALERT
### Components

| Layer | Tech | Notes |
|------:|------|------|
| Infra | AKS, ACR, Key Vault, Log Analytics | Terraform; RG pre-existing or data-sourced |
| Pools | `system:B2ms x1`, `work:B2ms x1` | Workloads run on `work` (no taint) |
| CI/CD | GitHub Actions | OIDC to Azure; PLAN/APPLY gates |
| GitOps | Helm (optionally Flux) | Flux extension unsupported in `eastus2` |
| Obsrv | kube-prometheus-stack | Grafana LB; retention 15d |
| Policy | Azure Policy add-on | Baseline guardrails |

---

## SRE & Compliance Mapping

| Practice | What’s Implemented | Evidence |
|---|---|---|
| **GitOps & Change Control** | Terraform in CI, artifacted plans; Helm releases recorded | Workflow logs, `tfplan` artifact |
| **Observability/SLOs** | Prometheus + Grafana + Alertmanager | `monitoring/*` evidence files, Grafana LB |
| **Secure Supply Chain** | ACR pull-only, OIDC auth, KV CSI hooks (stubs) | ACR `AcrPull` role assignment, GH secrets |
| **Resilience** | Split pools; controlled upgrades; reproducible infra | Node pools |
| **RBAC & Least Privilege** | Azure RBAC + scoped clusterrolebinding (temp) | `chad-cluster-admin` CRB; role assignment |
| **Governance** | Azure Policy add-on enabled | AKS add-on config; optional initiative |
| **Cost Hygiene** | B-series SKUs, single-node pools, stop/start AKS | `az aks stop/start` |

> Framework anchors: NIST 800-53 (CM, AC, AU, SI), FedRAMP CM/AC/IA, general GDPR/HIPAA process readiness.

---

## Deploy & Operate (Quick)

```bash
# 1) Apply infra (GitHub Actions)
gh workflow run "project-6-aks-infra" -f confirm=APPLY

# 2) Access cluster
az aks get-credentials -g rg-aks-gitops-lab -n p6-aks --overwrite-existing

# if RBAC denies, one-time admin then bind user
az aks get-credentials -g rg-aks-gitops-lab -n p6-aks --admin --overwrite-existing
USER_OBJID=$(az ad signed-in-user show --query id -o tsv)
kubectl create clusterrolebinding chad-cluster-admin \
  --clusterrole=cluster-admin --user="$USER_OBJID"
az aks get-credentials -g rg-aks-gitops-lab -n p6-aks --overwrite-existing

# 3) Install monitoring (Helm)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.prometheusSpec.retention=15d

# 4) Verify
kubectl -n monitoring get pods
kubectl -n monitoring get svc kube-prometheus-stack-grafana -o wide

## RBAC Model (Minimal)

```bash
# Azure RBAC at cluster scope (optional, preferred)
CLUSTER_ID=$(az aks show -g rg-aks-gitops-lab -n p6-aks --query id -o tsv)
USER_OBJID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee "$USER_OBJID" \
  --role "Azure Kubernetes Service RBAC Cluster Admin" --scope "$CLUSTER_ID"

# In-cluster temp binding (remove after group-based RBAC is set)
kubectl delete clusterrolebinding chad-cluster-admin || true

## Cost Controls

- Use `Standard_B2ms` pools (≥ AKS minimum), single-node per pool.
- Stop cluster when idle:
  ```bash
  az aks stop  -g rg-aks-gitops-lab -n p6-aks
  az aks start -g rg-aks-gitops-lab -n p6-aks
- Avoid Defender and heavy LA streaming in free tier.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| `Insufficient vcpu quota` | DSv5 family quota 0 | Use `B2ms`, single node |
| Pods Pending w/ `CriticalAddonsOnly` | Workloads on system node | Add a 1-node user pool or set system pool non-critical |
| `kubelogin not found` | Missing client credential plugin | `brew install azure/kubelogin/kubelogin` |
| Flux CRDs not found | Flux extension unsupported in region | Use Helm or move to a region that supports Flux |

## Evidence Checklist (for reviewers)

- `evidence/*/nodes.txt` — cluster node inventory  
- `evidence/*/monitoring-pods.txt` — monitoring stack running  
- `evidence/*/monitoring-svc.txt` — Grafana exposure  
- GitHub Actions run URL — plan/apply and artifacts
