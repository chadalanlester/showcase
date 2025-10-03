# Project 6 — Quick Run

## Deploy AKS (CI)
- Dispatch workflow `project-6-aks-infra` with `confirm=APPLY`.

## Access cluster
```bash
az aks get-credentials -g rg-aks-gitops-lab -n p6-aks --overwrite-existing
