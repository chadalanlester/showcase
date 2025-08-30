#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="project-1-multicloud-gitops"

echo "Scaffolding $PROJECT_DIR ..."
mkdir -p "$PROJECT_DIR"/{docs,terraform/{aws-eks,gcp-gke},k8s-manifests/{app,monitoring,argocd},ci-cd/.github/workflows,scripts}

# ---------- README ----------
cat > "$PROJECT_DIR/README.md" <<'MD'
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
MD
