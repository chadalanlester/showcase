# Showcase Workflows

Public, sanitized examples of CI/CD pipelines I run in my homelab.

## Highlights
- Multi-stage: lint → terraform plan.
- Dockerized Terraform on `ubuntu-latest`.
- Ready to extend with Ansible, Trivy, Syft, tfsec.

> Secrets are not required here. In real repos, configure secrets
> like `ANSIBLE_VAULT_PASSWORD` in repository settings.

## CI Status
![Showcase CI](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml/badge.svg)

## CI Status

![Showcase CI](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml/badge.svg?branch=main)
