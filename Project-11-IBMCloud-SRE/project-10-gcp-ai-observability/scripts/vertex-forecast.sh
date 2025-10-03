# showcase/project-10-gcp-ai-observability/scripts/vertex-forecast.sh
#!/usr/bin/env bash
# Run in Cloud Shell. Requires: curl, gcloud auth application-default login
set -euo pipefail

PROJECT="${PROJECT:-$(gcloud config get-value project)}"
REGION="${REGION:-us-central1}"
PROM_URL="${PROM_URL:-http://kube-prom-stack-prometheus.monitoring.svc.cluster.local:9090}"
NAMESPACE="${NAMESPACE:-monitoring}"

# 1) Pull last 2h CPU usage for kubelet as a proxy signal (lightweight)
QUERY='sum(rate(container_cpu_usage_seconds_total{container!="",pod!=""}[5m]))'
END=$(date +%s)
START=$((END-7200))
STEP=300

CPU_JSON=$(kubectl -n monitoring run curl-pod --image=curlimages/curl:8.10.1 -i --rm -q --restart=Never -- \
  curl -sG "${PROM_URL}/api/v1/query_range" --data-urlencode query="${QUERY}" --data-urlencode "start=${START}" --data-urlencode "end=${END}" --data-urlencode "step=${STEP}")

# 2) Ask Gemini for a one-paragraph capacity outlook (<= hourly use)
NOTE=$(python3 - "$CPU_JSON" <<'PY'
import os,sys,json
import subprocess, tempfile

data = json.loads(sys.argv[1])
series = []
if data.get("status")=="success":
  for r in data["data"]["result"]:
    vals = [float(v[1]) for v in r["values"]]
    series.extend(vals)
avg = sum(series)/len(series) if series else 0.0
trend = "flat"
if len(series) > 6 and series[-1] > avg*1.2: trend="rising"
elif len(series) > 6 and series[-1] < avg*0.8: trend="falling"

prompt = f"Given an average cluster CPU of {avg:.4f} cores per 5m sample and a {trend} trend, write one short sentence with a next-2h capacity outlook and a basic action."
# Use Vertex AI via gcloud CLI to avoid SDK boilerplate; returns text
# Requires 'gcloud alpha ai' or 'gcloud beta' depending on environment; keep as a placeholder:
print(f"CPU avg {avg:.4f}, trend {trend}. Keep replicas steady for now.")
PY
)

kubectl -n "${NAMESPACE}" delete configmap forecast-note --ignore-not-found
kubectl -n "${NAMESPACE}" create configmap forecast-note --from-literal=note="$NOTE"
echo "Wrote forecast to ConfigMap 'forecast-note'."
```

---

## How to use in VS Code (Mac)
- Open repo folder. Use Terminal panel. Run Cloud Shell steps in the browser; local steps in your Mac terminal.
- Recommended extensions: “HashiCorp Terraform”, “Kubernetes”, “YAML”, “Helm Intellisense”.

---

## Multi-cluster
Add more contexts using `scripts/set-kubecontext.sh` for each cluster, then:
```bash
kubectl config get-contexts
kubectl config use-context gke-<proj>-<region>-<cluster>
```

---

## Notes and references
- GKE Free Tier credit and scope.  [oai_citation:4‡Google Cloud](https://cloud.google.com/kubernetes-engine/pricing?utm_source=chatgpt.com)
- Managed Service for Prometheus pricing mechanics.  [oai_citation:5‡Google Cloud](https://cloud.google.com/managed-prometheus?utm_source=chatgpt.com)
- K8sGPT supports Gemini and local backends.  [oai_citation:6‡GitHub](https://github.com/k8sgpt-ai/k8sgpt?utm_source=chatgpt.com)
