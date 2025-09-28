# showcase/project-10-gcp-ai-observability/scripts/set-kubecontext.sh
#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${1:?project id}"
REGION="${2:-us-central1}"
CLUSTER="${3:-obs-ai-demo}"
gcloud container clusters get-credentials "$CLUSTER" --region "$REGION" --project "$PROJECT_ID"
kubectl config rename-context "gke_${PROJECT_ID}_${REGION}_${CLUSTER}" "gke-${PROJECT_ID}-${REGION}-${CLUSTER}"
kubectl config use-context "gke-${PROJECT_ID}-${REGION}-${CLUSTER}"
```

````bash
