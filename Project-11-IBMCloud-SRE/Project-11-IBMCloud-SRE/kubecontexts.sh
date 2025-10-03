#!/usr/bin/env bash
set -euo pipefail
aws eks update-kubeconfig --name demo-eks --region us-west-1 --alias eks || true
gcloud container clusters get-credentials demo-gke --zone us-central1-a --project chad-homelab
kubectl config get-contexts
