

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

## 📂 Repository Structure

```text
.github/workflows/
  ├── ci.yml         # Multi-stage CI/CD pipeline
  └── security.yml   # Dedicated security scans
terraform/
  └── main.tf        # Dummy Terraform configuration (safe null_resource)
ansible/
  └── site.yml       # Minimal playbook (debug task only)
.yamllint            # Linting rules (line length, truthy, empty lines)
README.md            # This document

---

🛡️ Security & Compliance
	•	All scans run in Docker containers, no host dependencies.
	•	No secrets required — workflows run safely in public without exposing credentials.
	•	SBOM artifacts are generated and uploaded for transparency.

---

💡 Key Practices Demonstrated
	•	✅ Multi-stage CI/CD with dependencies
	•	✅ Infrastructure-as-Code validation (Terraform)
	•	✅ Security scanning with Trivy, tfsec
	•	✅ SBOM generation (Syft)
	•	✅ Style compliance with yamllint
	•	✅ GitHub Actions badges for instant visibility

---

📝 Notes
	•	Terraform
Uses only null_resource → safe and non-destructive.
	•	Ansible
Playbook contains a simple debug message → illustrates CI integration, but does not target real hosts.
	•	Badges
Reflect the current status of CI and security scans on the main branch.

---

👀 For Employers

This repository is a showcase of my skills as an SRE.
It demonstrates:
	•	My ability to design and implement structured pipelines
	•	A strong focus on automation, security, and maintainability
	•	Hands-on experience across on-prem (homelab) and cloud platforms (Azure, AWS, GCP)
	•	A professional, transparent way of documenting and presenting technical work
