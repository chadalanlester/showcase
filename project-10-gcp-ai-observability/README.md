# showcase/project-10-gcp-ai-observability/README.md
# GCP AI-Powered Kubernetes Observability (Free-Tier)

## What you get
- GKE Autopilot cluster
- Prometheus + Grafana via Helm (light footprint)
- K8sGPT Operator wired to a free AI backend (Gemini or local)
- Optional Prometheus Adapter for HPA custom metrics
- Vertex AI hook for predictive notes (low-frequency, free-tier-safe)

## Why this stays free-tier
- GKE Free Tier credit: $74.40/month per billing account. Covers one Autopilot or one zonal Standard cluster’s control plane and a small footprint when idle. Keep workloads tiny and short-lived.  [oai_citation:0‡Google Cloud](https://cloud.google.com/kubernetes-engine/pricing?utm_source=chatgpt.com)
- Managed Prometheus: low sample rate and short retention. You control scrape/retention to keep ingest near zero.  [oai_citation:1‡Google Cloud](https://cloud.google.com/managed-prometheus?utm_source=chatgpt.com)
- Vertex AI: use Gemini free quotas with very low call rate (≤ hourly) or swap to local backend (Ollama/LocalAI) to avoid spend.  [oai_citation:2‡Google Cloud](https://cloud.google.com/vertex-ai/generative-ai/docs/quotas?utm_source=chatgpt.com)

---

## Architecture
- **GKE Autopilot** in a single region.
- **Monitoring namespace** with `kube-prometheus-stack` + `prometheus-adapter` (optional).
- **K8sGPT Operator** with filters (Ingress, Service, Pod, ReplicaSet, PVC, Node) and webhook sink.
- **Vertex AI** IAM ready; example Cloud Shell script calls Gemini periodically for “capacity forecast” notes.

---

## Deploy: steps and where to run

### Prereqs (Mac Studio, VS Code)
1. Install: `gcloud`, `terraform` (≥1.6), `kubectl`, `helm`.
2. Login:  
   ```bash
   gcloud auth login
   gcloud auth application-default login
   gcloud config set project <YOUR_GCP_PROJECT_ID>
   ```

### Phase 1: Cluster + K8sGPT (Cloud Shell recommended)
Run in **GCP Cloud Shell** for least friction.
```bash
cd showcase/project-10-gcp-ai-observability/terraform
terraform init
terraform apply -auto-approve \
  -var project_id=<YOUR_GCP_PROJECT_ID> \
  -var region=us-central1 \
  -var cluster_name=obs-ai-demo
```

Get kubeconfig on **Cloud Shell**:
```bash
gcloud container clusters get-credentials obs-ai-demo --region us-central1 --project <YOUR_GCP_PROJECT_ID>
kubectl get nodes
```

Deploy K8sGPT CRD resource (choose one backend):

A) **Gemini on Vertex AI** (uses minimal calls)
```bash
kubectl apply -f ../k8s-manifests/k8sgpt/k8sgpt-cr-gemini.yaml
```

B) **Local backend** via OpenAI-compatible endpoint (e.g., Ollama/LocalAI reachable within cluster; optional add-on)
```bash
kubectl apply -f ../k8s-manifests/k8sgpt/k8sgpt-cr-local.yaml
```

### Phase 2: Vertex AI predictive note (optional, free-tier-safe)
From **Cloud Shell**, run once/hour via Scheduler or manually to keep usage tiny:
```bash
bash ../scripts/vertex-forecast.sh
```
This pulls recent Prometheus CPU trend, asks Gemini for a short “capacity outlook” note, and writes to a ConfigMap Grafana can display.

### Phase 3: Observability stack
```bash
# Already installed by Terraform helm releases
kubectl -n monitoring get pods
```
Port-forward Grafana from **Cloud Shell**:
```bash
bash ../scripts/port-forward-grafana.sh
# Open http://127.0.0.1:3000 user: admin  pass: printed by script
```

### Phase 4: Advanced automation
- HPA example with custom metrics (Prometheus Adapter).
- K8sGPT webhook alerts to Slack/Cloud Run.
- Multi-cluster: add contexts and switch with helper script.

---

## GitOps notes
- Commit Terraform and manifests. Use branches + PRs. Conventional commits: `feat:`, `chore:`, `docs:`.
- Use VS Code Git panel. Push with signed commits if enabled.

---

## Free-tier guardrails
- One Autopilot cluster only. Tear down when done: `terraform destroy`.
- Prometheus scrape interval 60s, retention 12h, few targets only.
- Vertex AI calls ≤1 per hour or switch to local backend.

---

## SRE highlights
- **AI HPA**: HPA via Prometheus Adapter; example metric `http_requests_per_second`.
- **Predictive capacity**: Hourly trend + Gemini note. Keep to free quotas.  [oai_citation:3‡Google Cloud](https://cloud.google.com/vertex-ai/generative-ai/docs/quotas?utm_source=chatgpt.com)
- **Multi-cluster**: Kubeconfig contexts script provided.
- **Cost controls**: Tight scrape configs, low retention, minimal dashboards, autoscaling off for Grafana.

---

## Destroy
```bash
cd terraform
terraform destroy -auto-approve -var project_id=<YOUR_GCP_PROJECT_ID> -var region=us-central1 -var cluster_name=obs-ai-demo
```

