

## 👋 About Me

I’m **Chad Lester**, a **Site Reliability Engineer (SRE)**.
This repository is part of my professional portfolio — a **public showcase** of my skills and approach to automation, infrastructure-as-code, and DevSecOps practices.

I maintain a full homelab environment where I build and test modern infrastructure patterns using:
- 🖥️ **Proxmox** for virtualization
- ☸️ **Kubernetes** for orchestration
- 🛠️ **GitHub Actions** and **GitLab CI/CD** for pipelines
- 📦 **Docker**, **Terraform**, and **Ansible** for automation and provisioning
- 📊 **Prometheus**, **Grafana**, **Alertmanager** for monitoring and alerting

I also work with **public cloud providers** — **Azure**, **AWS**, and **Google Cloud** — and will be adding showcase workflows and IaC examples for these platforms.

This repository is meant for **employers** to review my skills in action: demonstrating clarity, automation, and security-first design.

---

# Showcase Workflows

This repository contains **sanitized, public-safe examples** of the CI/CD and DevSecOps pipelines I run in my homelab.
It demonstrates how I structure pipelines, enforce security scanning, and integrate Infrastructure-as-Code checks — without exposing real secrets or infrastructure.

---

## 🚀 Workflows

### Continuous Integration (CI)
[![Showcase CI](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml)

The **CI pipeline** runs automatically on pushes, pull requests, or manual dispatch.
It demonstrates a full multi-stage process:

- **Linting**
  - YAML lint (`yamllint`)
- **Infrastructure-as-Code (IaC)**
  - Terraform `init` + `plan`
- **Security scanning**
  - Trivy filesystem scan
  - tfsec Terraform security analysis
- **Software Bill of Materials (SBOM)**
  - Syft generates SPDX JSON artifact

### Security Scans
[![Security Scans](https://github.com/chadalanlester/showcase/actions/workflows/security.yml/badge.svg?branch=main)](https://github.com/chadalanlester/showcase/actions/workflows/security.yml)

The **Security workflow** provides a focused DevSecOps example:
- **Trivy** for vulnerability/misconfiguration scanning
- **tfsec** for Terraform static analysis
- **Syft** for SBOM generation and artifact upload

---

## 🛡️ Security & Compliance

- All scans run in **Docker containers**, no host dependencies.
- **No secrets required** — workflows run safely in public without exposing credentials.
- **SBOM artifacts** are generated and uploaded for transparency.

---

## 💡 Key Practices Demonstrated

- ✅ Multi-stage CI/CD with dependencies
- ✅ Infrastructure-as-Code validation (Terraform)
- ✅ Security scanning with Trivy, tfsec
- ✅ SBOM generation (Syft)
- ✅ Style compliance with yamllint
- ✅ GitHub Actions badges for instant visibility

---

## 🧰 Technologies × Workflows

| Technology / Tool | Showcase CI | Security Scans |
|-------------------|-------------|----------------|
| **YAML Lint (yamllint)** | ✅ | ❌ |
| **Terraform (init/plan)** | ✅ | ✅ (scanned with tfsec) |
| **Ansible** | Demo playbook included | ❌ |
| **Trivy** | ✅ (filesystem scan) | ✅ (filesystem scan) |
| **tfsec** | ✅ | ✅ |
| **Syft (SBOM)** | ✅ | ✅ |
| **Docker** | ✅ (all jobs run via Docker images) | ✅ |
| **GitHub Actions** | ✅ | ✅ |

✅ = tool is actively used in that workflow
❌ = not applicable

---

## 📝 Notes

- **Terraform** → Uses only `null_resource` → safe and non-destructive.
- **Ansible** → Playbook contains a simple `debug` message → illustrates CI integration, but does not target real hosts.
- **Badges** → Reflect the current status of CI and security scans on the `main` branch.

---

## 👀 For Employers

This repository is a **showcase of my skills as an SRE**.
It demonstrates:
- My ability to design and implement structured pipelines
- A strong focus on **automation, security, and maintainability**
- Hands-on experience across **on-prem (homelab)** and **cloud platforms (Azure, AWS, GCP)**
- A professional, transparent way of documenting and presenting technical work

---

# 🚀 SRE Showcase – Multi-Cloud & Resilience Projects

This repository demonstrates **Site Reliability Engineering (SRE)** practices across multiple clouds (AWS EKS, GCP GKE), GitOps (Argo CD), observability (Prometheus & Grafana), and resilience testing (chaos engineering).

It is structured as a series of projects that build on one another.

---

## 🌍 Project 1: Multi-Cloud GitOps with Argo CD

**Goal:** Deploy and manage workloads on **both AWS EKS and GCP GKE** clusters using **Argo CD GitOps**.

### Key Features
- Terraform to provision:
  - AWS EKS in `us-west-1`
  - GCP GKE in `us-central1-a`
- Argo CD installed in each cluster
- App-of-Apps pattern for GitOps sync
- Monitoring stack: Prometheus, Grafana, Alertmanager
- Evidence of successful deployments in [docs/](./docs)

### Evidence
- ✅ EKS and GKE both run the **Hello Demo app** via Argo CD
- ✅ Grafana exposed via LoadBalancer
- ✅ Prometheus CRDs installed and scraping targets

📄 See detailed Terraform + Argo manifests in:
- [`project-1-multicloud-gitops/terraform/aws-eks`](./project-1-multicloud-gitops/terraform/aws-eks)
- [`project-1-multicloud-gitops/terraform/gcp-gke`](./project-1-multicloud-gitops/terraform/gcp-gke)
- [`project-1-multicloud-gitops/k8s-manifests`](./project-1-multicloud-gitops/k8s-manifests)

---

## 🏗️ Project 2: Case Platform (Vendor-Scrubbed)

**Goal:** Adapt a previous Filevine technical exercise into a neutral,
publishable SRE project.

### Key Features
- Terraform IaC for AWS VPC, EC2, Security Groups
- Monitoring setup with CloudWatch and alerts
- Scripts to bootstrap demo app on EC2
- Sanitized of vendor-specific references (`filevine` → `acme`)

### Evidence
- ✅ EC2 instance with monitoring and security groups
- ✅ Clean public GitHub repo with history rewritten via `git-filter-repo`

📄 See full project here:  
[`case-platform-project`](./case-platform-project)

---

## 🌐 Project 3: Multi-Cloud GitOps (EKS + GKE)

**Goal:** Deploy workloads consistently across **AWS EKS** and **GCP GKE**
using **Argo CD** + **Terraform**.

### Key Features
- Terraform IaC for:
  - AWS EKS cluster
  - GCP GKE cluster
- Argo CD App-of-Apps pattern
- Monitoring stack (Prometheus + Grafana)
- Documentation of kubeconfig switching with helper script

### Evidence
- ✅ EKS and GKE clusters provisioned
- ✅ Demo `hello` app deployed via Argo CD
- ✅ Monitoring dashboards accessible on both clouds

📄 See full project here:  
[`project-1-multicloud-gitops`](./project-1-multicloud-gitops)

---

## 🛡️ Project 4: Resilient Web Application with Self-Healing

**Goal:** Showcase Kubernetes self-healing, autoscaling, chaos testing, and
resilience validation using a fun **Flask Trivia API**.

### Key Features
- **Flask app** serving random DevOps trivia
- **Kubernetes Deployment** with:
  - Liveness + Readiness probes
  - PodDisruptionBudget (PDB)
  - HorizontalPodAutoscaler (HPA)
- **Argo CD GitOps** for automated sync
- **Chaos Engineering** with Python scripts:
  - `chaos_kill_pods.py` → randomly deletes pods
  - `load_gen.py` → synthetic load to trigger HPA
  - `remediate_restart.py` → auto rollout restart if replicas too low
  - `check_slo.py` → check Prometheus SLO compliance
- **GitHub Actions** workflow `resilience.yml` runs:
  - Build + push container to GHCR
  - Chaos test + load gen
  - Optional SLO validation

### Evidence
- ✅ Pods recover after chaos kills
- ✅ HPA scales out under load
- ✅ Prometheus metrics integrated
- ✅ GitHub Actions pipeline executes resilience tests

📄 See full project here:  
[`project-4-resilient-app`](./project-4-resilient-app)

---

## 🧹 Cleanup & Cost Control

Because these projects use **AWS Free Tier** and **GCP trial credits**, all
resources should be torn down after testing to avoid unnecessary charges.

### Teardown Steps

1. **Delete demo namespaces** (removes apps, services, ELBs, HPAs, PDBs):
   ```bash
   kubectl delete ns demo resilient monitoring --wait=true

2. **Destroy Argo CD** (optional if not reused):
   ```bash
   helm uninstall argocd -n argocd
   kubectl delete ns argocd --wait=true

3. **Tear down AWS EKS**  
   ```bash
   cd project-1-multicloud-gitops/terraform/aws-eks
   export AWS_PROFILE=AdministratorAccess-<account_id>
   terraform destroy -auto-approve \
     -var region=us-west-1 \
     -var principal_arn=$PRINCIPAL_ARN

4. **Tear down GKE**  
   ```bash
   cd project-1-multicloud-gitops/terraform/gcp-gke
   terraform destroy -auto-approve \
     -var "project=chad-homelab" \
     -var "region=us-central1-a"

