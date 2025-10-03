# 🚀 SRE Portfolio Showcase

**Chad Lester** | Site Reliability Engineer  
**Professional Portfolio for Prospective Employers**

[![Showcase CI](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml/badge.svg)](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml)
[![Security Scans](https://github.com/chadalanlester/showcase/actions/workflows/security.yml/badge.svg)](https://github.com/chadalanlester/showcase/actions/workflows/security.yml)

---

## 👋 About This Portfolio

This repository is **my professional showcase** as a **Site Reliability Engineer**. It contains **production-ready examples** and **working demonstrations** of enterprise SRE practices across multi-cloud environments. 

**For Hiring Managers & Technical Interviewers**: Each project demonstrates real-world SRE skills with **evidence-based delivery**, showing not just what I can build, but how I operate, monitor, and maintain systems at scale.

### 🎯 What This Demonstrates
- ✅ **Multi-cloud expertise** across AWS, Azure, and GCP
- ✅ **Infrastructure-as-Code** mastery with Terraform and Ansible  
- ✅ **Kubernetes-first** approach with GitOps and observability
- ✅ **DevSecOps integration** with automated security scanning
- ✅ **Cost-conscious engineering** using free-tier resources
- ✅ **Professional documentation** and evidence capture

---

## 🛠️ Core Technologies

| Category | Technologies |
|----------|-------------|
| **☸️ Orchestration** | Kubernetes, Docker, Helm |
| **🏗️ Infrastructure** | Terraform, Ansible, Proxmox |
| **☁️ Cloud Providers** | AWS (EKS), Azure (AKS), GCP (GKE) |
| **🔄 GitOps** | Argo CD, FluxCD |
| **📊 Monitoring** | Prometheus, Grafana, Alertmanager, CloudWatch |
| **🔒 Security** | Trivy, tfsec, RBAC, Network Policies |
| **🚀 CI/CD** | GitHub Actions, GitLab CI/CD |

---

## 🔧 Automated Workflows

### 🏗️ [Showcase CI](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml)
**Multi-stage pipeline demonstrating production CI/CD practices:**
- 📝 **Code Quality**: YAML linting (yamllint)
- 🏗️ **Infrastructure**: Terraform validation (init/plan)
- 🛡️ **Security**: Trivy vulnerability scans, tfsec analysis
- 📋 **Compliance**: SBOM generation with Syft

### 🔐 [Security Scans](https://github.com/chadalanlester/showcase/actions/workflows/security.yml)
**DevSecOps-focused security automation:**
- 🔍 Container vulnerability scanning (Trivy)
- 🔒 Infrastructure security analysis (tfsec)
- 📦 Supply chain transparency (SBOM artifacts)

---

## 📁 Project Portfolio

> **For Employers**: Each project includes **evidence artifacts**, **screenshots**, and **validation steps** proving successful deployment and operation.

### 1. 🌐 Multi-Cloud GitOps with Argo CD
**Path**: `project-1-multicloud-gitops`

**Demonstrates**: Multi-cloud orchestration and GitOps mastery
- 🏗️ Terraform provisioning across AWS EKS and GCP GKE
- 🔄 Argo CD App-of-Apps pattern implementation
- 📊 End-to-end monitoring stack (Prometheus, Grafana, Alertmanager)
- 🌍 Cross-cloud workload synchronization

**💡 Key Skills**: Multi-cloud architecture, GitOps workflows, infrastructure automation  
**📸 Evidence**: Working applications in both clouds, operational dashboards

### 2. 🏗️ Case Platform (Vendor-Neutral)
**Path**: `project-2-case-platform`

**Demonstrates**: Enterprise infrastructure patterns and interview-ready solutions
- 🔧 AWS VPC and EC2 provisioning with Terraform
- 🛡️ Security group configuration and monitoring
- 📈 CloudWatch alarms and observability
- 🏢 Sanitized enterprise architecture patterns

**💡 Key Skills**: AWS infrastructure, security design, monitoring setup  
**📸 Evidence**: Deployed infrastructure, monitoring configurations

### 3. ☸️ Multi-Cloud Kubernetes (EKS + GKE)
**Path**: `project-3-multicloud-k8s`

**Demonstrates**: Kubernetes expertise across cloud providers
- 🏗️ Infrastructure-as-Code for AWS and GCP clusters
- 🔄 Consistent GitOps deployment patterns
- 📊 Unified monitoring across cloud boundaries
- 🔧 Kubeconfig management automation

**💡 Key Skills**: Kubernetes operations, cloud-agnostic design, automation  
**📸 Evidence**: Cross-cloud application deployments, unified dashboards

### 4. 🔄 Resilient Web Application with Self-Healing
**Path**: `project-4-resilient-app`

**Demonstrates**: Production reliability and chaos engineering
- ⚕️ Kubernetes health probes and self-healing
- 📈 Horizontal Pod Autoscaling and Pod Disruption Budgets
- 🎭 Chaos testing and failure recovery
- 📊 SLO validation with Prometheus metrics

**💡 Key Skills**: Site reliability patterns, chaos engineering, performance optimization  
**📸 Evidence**: Automated recovery demonstrations, scaling under load, metrics validation

### 5. ☁️ AWS CloudFormation SRE Showcase
**Path**: `project-5-aws-cloudformation`

**Demonstrates**: AWS-native automation and self-healing systems
- 🏗️ CloudFormation infrastructure-as-code
- 🤖 Lambda-based health checking and auto-remediation
- 🚨 CloudWatch alarms and SNS alerting
- 💰 Cost-optimized free-tier design

**💡 Key Skills**: AWS automation, serverless operations, cost optimization  
**📸 Evidence**: Self-healing demonstrations, alert testing, cost compliance

### 6. ⚙️ Azure AKS GitOps
**Path**: `project-6-azure-aks-gitops`

**Demonstrates**: Enterprise Azure Kubernetes operations
- 🏗️ Terraform automation with GitHub Actions
- 🔐 Azure RBAC integration and ACR connectivity
- 🔑 Key Vault CSI driver preparation
- 🛡️ Network policies and security controls

**💡 Key Skills**: Azure expertise, enterprise security, Kubernetes governance  
**📸 Evidence**: Production-ready cluster, security configurations, monitoring stack

### 7. 🌐 Azure HA Web on Hub-Spoke Architecture
**Path**: `project-7-azure-ha-web`

**Demonstrates**: High-availability web services and network design
- 🏗️ Hub-Spoke network topology implementation
- 📈 VM Scale Sets with intelligent auto-scaling
- ⚖️ Application Gateway health probing
- 🛡️ Network security and traffic management

**💡 Key Skills**: Network architecture, high availability design, Azure expertise  
**📸 Evidence**: HA validation, scaling demonstrations, health check verification

### 8. 🧹 Cleanup & Cost Control
**Path**: `project-8-cleanup-cost-control`

**Demonstrates**: Operational discipline and cost management
- 💰 **Cost Optimization**: Free-tier compliance across all projects
- 🗑️ **Resource Lifecycle**: Automated teardown workflows
- 📊 **Audit Trail**: Evidence capture before resource deletion
- 🌐 **Multi-Cloud**: Cleanup procedures for AWS, Azure, GCP

**💡 Key Skills**: Cost management, operational governance, resource lifecycle  
**📸 Evidence**: Cost monitoring, cleanup automation, audit documentation

### 9. 🤖 AWS AI Feedback Triage
**Path**: `project-9-aws-ai-feedback-triage` | **Tag**: `v1.0.1`

**Demonstrates**: Serverless AI integration and event-driven architecture
- 📥 **Serverless Ingestion**: API Gateway and S3 batch processing
- 🧠 **AI Processing**: Amazon Comprehend sentiment and entity analysis
- 🗄️ **Data Persistence**: DynamoDB storage with event streaming
- 🚨 **Intelligent Alerting**: SNS notifications and CloudWatch dashboards

**💡 Key Skills**: Serverless architecture, AI/ML integration, event-driven design  
**📸 Evidence**: Architecture diagrams, API testing, real-time processing demos

### 10. 🔍 GCP AI-Powered Observability
**Path**: `project-10-gcp-ai-observability`

**Demonstrates**: Next-generation observability with AI-assisted operations
- ☸️ **Modern Platform**: GKE Autopilot cluster automation
- 📊 **Comprehensive Monitoring**: Prometheus, Grafana, kube-state-metrics
- 🤖 **AI Operations**: K8sGPT operator for intelligent troubleshooting
- 🏗️ **Infrastructure Automation**: Complete Terraform provisioning

**💡 Key Skills**: Modern observability, AI-assisted operations, Google Cloud expertise  
**📸 Evidence**: AI diagnostic outputs, monitoring dashboards, automated insights

---

## 🔒 Security & Compliance

### 🛡️ Security-First Approach
- 🔍 **Vulnerability Scanning**: Trivy container and filesystem analysis
- 🏗️ **Infrastructure Security**: tfsec static analysis for Terraform
- 📦 **Supply Chain**: SBOM generation and dependency tracking
- 🔐 **Access Control**: RBAC implementation across all platforms
- 🌐 **Network Security**: Network policies, security groups, firewalls

### 📋 Compliance & Governance
- 📝 **Audit Trail**: Git-based change tracking for all infrastructure
- 📊 **Evidence Collection**: Runtime artifacts and validation screenshots
- 🔒 **Policy Enforcement**: Automated security scanning in CI/CD pipelines
- 💰 **Cost Compliance**: Free-tier boundaries respected across projects

---

## ✅ Quality Assurance

### 🔧 Automated Testing
- 📝 **Code Standards**: YAML, Terraform, Python linting
- 🔒 **Security Gates**: Pre-commit hooks with vulnerability scanning
- 🏗️ **Infrastructure Validation**: Terraform plan verification
- 📚 **Documentation**: Markdown consistency and completeness

### 📸 Evidence-Based Delivery
- 🖼️ **Visual Proof**: Dashboard screenshots and system state captures
- 📄 **Configuration Artifacts**: Exported manifests and runtime configs
- 📊 **Operational Logs**: Deployment evidence and system metrics
- ⚡ **Performance Data**: SLI/SLO measurements and reliability metrics

---

## 🚀 Why This Matters for Employers

### 💼 Real-World Application
**This isn't theoretical knowledge** - every project runs on actual infrastructure with real costs, real monitoring, and real operational challenges. I've solved the problems you'll face in production.

### 🎯 Hiring Confidence
- ✅ **Proven Expertise**: Working demonstrations across multiple cloud platforms
- ✅ **Best Practices**: Industry-standard tools and methodologies
- ✅ **Documentation Skills**: Clear, professional technical writing
- ✅ **Cost Awareness**: Efficient resource usage and budget consciousness
- ✅ **Security Mindset**: Security-by-default in all implementations

### 🔄 Immediate Value
**Day-one productivity** with demonstrated experience in:
- Modern infrastructure patterns you're already using
- Tools and platforms in your current stack
- Operational practices that scale with your business

---

## 📞 Let's Connect

Ready to discuss how these skills apply to your SRE challenges?

- 💼 **LinkedIn**: [linkedin.com/in/chadalanlester](https://www.linkedin.com/in/chadalanlester)
- 🐙 **GitHub**: [github.com/chadalanlester](https://github.com/chadalanlester)  
- 📧 **Email**: [chad@chadlester.com](mailto:chad@chadlester.com)

---

**🎯 For Technical Interviewers**: Each project includes detailed setup instructions, evidence artifacts, and operational runbooks. Pick any project for deep-dive technical discussions - they're all production-ready and thoroughly documented.


### Fun
# 🧠 The Oracle of Slumber: An AI Dream Interpreter

A playful **Python** program that integrates with the **OpenAI API** to generate psychoanalytic-style dream interpretations.  
Choose between two personas — Freud or Jung — and see how role-specific prompts can produce dramatically different analyses.

---

## Why It’s Interesting

- **Python + OpenAI Integration**  
  Demonstrates a clean, minimal example of using Python with the `openai` library to call modern LLM APIs.  
- **Prompt Engineering**  
  Uses role-based “system prompts” to simulate distinct analyst personas.  
- **Enterprise Relevance**  
  While this demo is whimsical, the same pattern — Python + LLM API + persona-specific prompts — is directly applicable to serious enterprise cases such as:
  - Customer support assistants adopting brand voice
  - Compliance advisors that enforce regulatory tone
  - Knowledge retrieval bots with domain-specific personalities

This makes the project both a fun showcase and a transferable coding pattern.

---

## Setup

Requires **Python 3.10+** and an **OpenAI API key**.

```bash
# Clone repo and enter folder
cd fun/dream_interpreter

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

# Install dependency
pip install --upgrade pip
pip install -r requirements.txt

# Set your API key (macOS/Linux)
export OPENAI_API_KEY=sk-...

# Windows (PowerShell)
setx OPENAI_API_KEY "sk-..."
