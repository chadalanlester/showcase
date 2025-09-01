# Case Platform SRE Challenge – Chad Lester

## Overview

This project demonstrates a complete, automated infrastructure deployment using:

- **Terraform** (modular structure)
- **AWS EC2** with **Dockerized NGINX** (custom cloud-init)
- **Monitoring** with Node Exporter and NGINX Exporter
- **Git-based workflow** with feature branches and CI-ready layout

## Architecture

- **Two EC2 Instances**:
  - `nginx`: Serves a static HTML page via NGINX in Docker
  - `monitoring`: Intended for Prometheus, pre-configured with Node Exporter
- **Security Groups**:
  - Allow SSH, HTTP, and exporter ports (9100, 9113)
- **Cloud-Init**:
  - Automates Docker install, NGINX setup, HTML deployment
  - Node Exporter and NGINX Exporter autostart via cloud-init or manual fallback

## Observability

- **Node Exporter**: `http://<nginx_ip>:9100/metrics`
- **NGINX Exporter**: `http://<nginx_ip>:9113/metrics`
- **Stub Status**: `http://<nginx_ip>/stub_status`
- **Static Web**: `http://<nginx_ip>`

## Usage

### Terraform

```bash
make init     # Initialize providers and modules
make apply    # Deploy infra and run cloud-init
make destroy  # Tear everything down
make output   # Get public IPs

