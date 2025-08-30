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
