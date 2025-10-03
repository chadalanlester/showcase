# Multi-Cloud Kubernetes with GitOps

## Objective
Provision EKS and GKE with Terraform. Install Argo CD. Operate apps and monitoring via GitOps.

## Architecture
![diagram](docs/arch-diagram.png)

**Flow:** Dev commits → GitHub Actions plans and applies infra → Argo CD reconciles app and monitoring manifests → Services exposed with LoadBalancer on each cloud.

## Prerequisites
- macOS with Homebrew
- AWS and GCP accounts
- GitHub repo with Actions enabled

## Setup
```bash
# 1) Clone
gh repo clone <you>/<repo>
cd <repo>/project-1-multicloud-gitops

# 2) AWS EKS
cd terraform/aws-eks && terraform init && terraform apply -auto-approve

# 3) GCP GKE
cd ../gcp-gke && terraform init && terraform apply -auto-approve

# 4) Configure kubecontexts
../../scripts/kubecontexts.sh

# 5) Bootstrap Argo CD per cluster
../../scripts/bootstrap-argocd.sh eks
../../scripts/bootstrap-argocd.sh gke

# 6) Verify
../../scripts/verify.sh
## 🌍 Multi-Cloud GitOps Showcase (AWS EKS + GCP GKE)

This project demonstrates a **multi-cloud GitOps workflow** using [Argo CD](https://argo-cd.readthedocs.io/) to manage applications across **AWS EKS** and **Google GKE**.

### 🏗️ Infrastructure Setup

We use Terraform for repeatable IaC:

- **AWS (EKS)**:
  - Creates a VPC, subnets, EKS control plane, and node groups.
  - Configures IAM roles for cluster + nodes.
  - Installs Argo CD via Helm.

- **GCP (GKE)**:
  - Creates a zonal cluster (`us-central1-a`) to avoid regional SSD quota issues.
  - Installs Argo CD via Helm.
  - Uses the same GitOps manifests to deploy workloads.

### 🚀 GitOps Flow

1. **Argo CD Installation**
   - Installed via Helm in both clusters.
   - Exposed via `LoadBalancer` service for UI access.
   - Admin password stored in Kubernetes Secret (`argocd-initial-admin-secret`).

2. **App-of-Apps Pattern**
   - `project-1-multicloud-gitops/k8s-manifests/argocd/app-of-apps.yaml`
   - Syncs everything under `k8s-manifests/`.
   - Includes:
     - `app/hello`: demo app (`nginxdemos/hello`)
     - `monitoring/`: kube-prometheus-stack with Grafana/Prometheus/Alertmanager

3. **Demo App**
   - Simple HTTP echo service
   - Exposed via cloud LoadBalancer:
     - `http://<EKS-ELB>`
     - `http://<GKE-LB>`

4. **Observability**
   - Grafana exposed via LoadBalancer.
   - Prometheus scrapes `hello` deployment.
   - Custom alert rule added to fire if replicas drop to 0.

### 📜 Evidence

- [docs/eks-nodes.txt](docs/eks-nodes.txt) — EKS cluster node listing
- [docs/gke-nodes.txt](docs/gke-nodes.txt) — GKE cluster node listing
- [docs/demo-app.txt](docs/demo-app.txt) — Hello app service + rollout
- [docs/monitoring.txt](docs/monitoring.txt) — Monitoring stack pods/services
- [docs/argocd.txt](docs/argocd.txt) — ArgoCD application state

### 🧹 Teardown

When finished, **always destroy** to avoid cloud costs:

```bash
# AWS EKS
cd project-1-multicloud-gitops/terraform/aws-eks
terraform destroy -auto-approve -var region=us-west-1

# GCP GKE
cd project-1-multicloud-gitops/terraform/gcp-gke
terraform destroy -auto-approve -var project=chad-homelab -var region=us-central1-a
