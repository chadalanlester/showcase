# GCP AI-Powered Kubernetes Observability

**Project Status**: Active | **Cost Profile**: Free-Tier Compliant | **Platform**: GKE Autopilot

## Overview

Production-ready observability stack on Google Cloud demonstrating modern SRE practices with AI-assisted operations. This project showcases comprehensive monitoring, intelligent troubleshooting, and predictive capacity planning while maintaining strict free-tier cost controls.

### Architecture Components
- **GKE Autopilot cluster** with optimized resource allocation
- **Prometheus + Grafana** via Helm with minimal resource footprint
- **K8sGPT Operator** with AI-powered cluster analysis
- **Vertex AI integration** for predictive capacity insights
- **Custom metrics HPA** via Prometheus Adapter

### Free-Tier Cost Controls
- **GKE Free Tier**: $74.40/month credit covers Autopilot control plane ([GKE Pricing](https://cloud.google.com/kubernetes-engine/pricing))
- **Managed Prometheus**: Minimal scrape intervals and short retention ([Cloud Monitoring](https://cloud.google.com/monitoring/pricing))
- **Vertex AI**: Gemini free quotas with ≤1 call/hour ([Vertex AI Quotas](https://cloud.google.com/vertex-ai/generative-ai/docs/quotas))

---

## Prerequisites

### Required Tools (Run on Mac Studio/Local Workstation)
```bash
# Install required CLI tools
brew install google-cloud-sdk terraform kubectl helm

# Verify installations
gcloud version
terraform version
kubectl version --client
helm version
```

### GCP Project Setup
1. **Create GCP Project**:
   ```bash
   export PROJECT_ID="your-project-id"
   gcloud projects create ${PROJECT_ID}
   gcloud config set project ${PROJECT_ID}
   ```

2. **Enable Required APIs**:
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable compute.googleapis.com
   gcloud services enable monitoring.googleapis.com
   gcloud services enable aiplatform.googleapis.com
   ```

3. **Authentication Setup**:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

4. **Verify Billing Account**:
   ```bash
   gcloud billing accounts list
   gcloud billing projects link ${PROJECT_ID} --billing-account=BILLING_ACCOUNT_ID
   ```

---

## Deployment Guide

### Phase 1: Infrastructure Provisioning

**Location**: Run from **GCP Cloud Shell** for optimal network performance and authentication.

```bash
# Navigate to project directory
cd ~/showcase/project-10-gcp-ai-observability/terraform

# Initialize Terraform
terraform init

# Review deployment plan
terraform plan \
  -var="project_id=${PROJECT_ID}" \
  -var="region=us-central1" \
  -var="cluster_name=obs-ai-demo"

# Deploy infrastructure
terraform apply -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="region=us-central1" \
  -var="cluster_name=obs-ai-demo"
```

**Validation Steps**:
```bash
# Configure kubectl
gcloud container clusters get-credentials obs-ai-demo \
  --region us-central1 --project ${PROJECT_ID}

# Verify cluster status
kubectl get nodes -o wide
kubectl get pods -A --field-selector=status.phase!=Running

# Check resource usage
kubectl top nodes
```

### Phase 2: K8sGPT Operator Configuration

**Choose AI Backend** (select one option):

#### Option A: Vertex AI Gemini (Recommended)
```bash
# Deploy K8sGPT with Gemini backend
kubectl apply -f ../k8s-manifests/k8sgpt/k8sgpt-cr-gemini.yaml

# Verify deployment
kubectl get k8sgpt -n k8sgpt-operator-system
kubectl logs -n k8sgpt-operator-system -l app=k8sgpt-operator
```

#### Option B: Local AI Backend (Cost-Free Alternative)
```bash
# Deploy with local backend
kubectl apply -f ../k8s-manifests/k8sgpt/k8sgpt-cr-local.yaml

# Verify configuration
kubectl describe k8sgpt k8sgpt-sample -n k8sgpt-operator-system
```

**Validation Commands**:
```bash
# Test K8sGPT analysis
kubectl get events --sort-by='.lastTimestamp' | head -10
kubectl get k8sgpt -o yaml
```

### Phase 3: Monitoring Stack Verification

```bash
# Check monitoring namespace resources
kubectl get pods -n monitoring -o wide
kubectl get svc -n monitoring
kubectl get pvc -n monitoring

# Verify Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
# Navigate to http://localhost:9090/targets

# Access Grafana dashboard
bash ../scripts/port-forward-grafana.sh
# Credentials displayed by script - Default: admin/admin
```

**Monitoring Validation**:
```bash
# Test Prometheus metrics collection
curl -s http://localhost:9090/api/v1/query?query=up | jq '.data.result'

# Verify Grafana datasource
curl -u admin:admin http://localhost:3000/api/datasources
```

### Phase 4: AI-Powered Insights (Optional)

**Predictive Capacity Analysis**:
```bash
# Run capacity forecast (max once per hour for free-tier compliance)
bash ../scripts/vertex-forecast.sh

# Verify forecast data
kubectl get configmap ai-insights -n monitoring -o yaml
```

**Custom Metrics HPA Setup**:
```bash
# Deploy HPA with Prometheus Adapter
kubectl apply -f ../k8s-manifests/hpa/custom-metrics-hpa.yaml

# Verify custom metrics
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq .
```

---

## Operations & Monitoring

### Health Checks
```bash
# Cluster health overview
kubectl get componentstatuses
kubectl top nodes
kubectl top pods -A

# K8sGPT analysis results
kubectl get results -A
kubectl describe result -n default <result-name>

# AI insights validation
kubectl logs -n monitoring -l app=ai-forecast
```

### Cost Monitoring
```bash
# Check current GKE usage
gcloud container clusters describe obs-ai-demo \
  --region us-central1 --format="value(currentNodeCount,status)"

# Monitor Vertex AI API usage
gcloud logging read "resource.type=aiplatform.googleapis.com" \
  --limit=10 --format="table(timestamp,severity,textPayload)"
```

### Troubleshooting

#### Common Issues & Solutions

**1. Authentication Errors**:
```bash
gcloud auth list
gcloud auth application-default login
```

**2. API Quota Exceeded**:
```bash
gcloud services list --enabled
gcloud quota list --service=aiplatform.googleapis.com
```

**3. Resource Constraints**:
```bash
kubectl describe nodes
kubectl get events --sort-by=.metadata.creationTimestamp | tail -20
```

**4. K8sGPT Operator Issues**:
```bash
kubectl logs -n k8sgpt-operator-system deployment/k8sgpt-operator-controller-manager
kubectl get k8sgpt -o yaml | grep -A 10 status
```

---

## Evidence & Validation

### Captured Artifacts
- **Cluster State**: `artifacts/cluster-info.yaml`
- **Prometheus Targets**: `artifacts/prometheus-targets.json`
- **Grafana Dashboards**: `screenshots/grafana-*.png`
- **K8sGPT Analysis**: `artifacts/k8sgpt-results.yaml`
- **AI Insights**: `artifacts/vertex-ai-responses.json`

### Performance Metrics
```bash
# Capture current state for documentation
kubectl cluster-info dump > artifacts/cluster-dump.yaml
kubectl get all -A -o yaml > artifacts/all-resources.yaml

# Export Prometheus configuration
kubectl get configmap prometheus-server -n monitoring -o yaml > artifacts/prometheus-config.yaml
```

---

## GitOps Integration

### Repository Management
```bash
# Commit infrastructure changes
git checkout -b feature/gcp-observability-update
git add terraform/ k8s-manifests/ scripts/
git commit -S -m "feat: enhance GCP AI observability stack"
git push origin feature/gcp-observability-update
```

### Continuous Integration
- **Pre-commit hooks**: yamllint, terraform fmt, kubernetes manifest validation
- **CI Pipeline**: Terraform plan validation, security scanning (tfsec, trivy)
- **Evidence Collection**: Automated artifact generation and screenshot capture

---

## Advanced Features

### Multi-Cluster Operations
```bash
# Switch between cluster contexts
bash ../scripts/switch-cluster-context.sh obs-ai-demo us-central1

# Cross-cluster monitoring federation
kubectl apply -f ../k8s-manifests/federation/prometheus-federation.yaml
```

### Predictive Scaling
```bash
# Deploy ML-based HPA
kubectl apply -f ../k8s-manifests/hpa/predictive-hpa.yaml

# Monitor scaling decisions
kubectl get hpa -w
kubectl describe vpa recommendation-vpa
```

### Security Integration
```bash
# Network policy validation
kubectl apply -f ../k8s-manifests/security/network-policies.yaml

# RBAC audit
kubectl auth can-i --list --as=system:serviceaccount:monitoring:prometheus
```

---

## Cleanup & Cost Control

### Complete Infrastructure Teardown
```bash
# Destroy all resources
cd terraform
terraform destroy -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="region=us-central1" \
  -var="cluster_name=obs-ai-demo"

# Verify cleanup
gcloud container clusters list
gcloud compute disks list --filter="zone:us-central1"
gcloud logging sinks list
```

### Cost Verification
```bash
# Final cost check
gcloud billing budgets list
gcloud logging read "protoPayload.serviceName=container.googleapis.com" \
  --limit=10 --format="value(timestamp,resource.labels.cluster_name)"
```

---

## SRE Best Practices Demonstrated

### ✅ Observability
- **Multi-layered monitoring** with Prometheus, Grafana, and custom metrics
- **Intelligent alerting** via K8sGPT analysis and threshold-based alarms
- **Predictive insights** using Vertex AI for capacity planning

### ✅ Automation
- **Infrastructure-as-Code** with Terraform modules and GitOps workflows
- **Self-healing systems** with HPA and cluster autoscaling
- **AI-assisted operations** reducing manual troubleshooting effort

### ✅ Cost Engineering
- **Free-tier optimization** with resource limits and usage monitoring
- **Automated cleanup** preventing cost overruns
- **Usage tracking** with detailed billing and quota monitoring

### ✅ Security & Compliance
- **RBAC implementation** with minimal privilege principles
- **Network segmentation** using Kubernetes Network Policies
- **Audit logging** for compliance and troubleshooting

---

## Evidence for Technical Interviews

This project provides concrete discussion points for SRE interviews:

1. **Observability Strategy**: How monitoring architectures scale across cloud platforms
2. **AI Integration**: Practical applications of ML in operations and capacity planning  
3. **Cost Optimization**: Balancing feature richness with budget constraints
4. **Automation Philosophy**: When and how to implement self-healing systems
5. **Multi-cloud Expertise**: Translating patterns across GCP, AWS, and Azure

**All configurations, scripts, and evidence artifacts are included in this repository for hands-on demonstration during technical discussions.**