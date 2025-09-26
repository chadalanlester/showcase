## **👋 About Me**  
  
I’m **Chad Lester**, a **Site Reliability Engineer (SRE)**.   
This repository is part of my professional portfolio — a **public showcase** of my skills and approach to automation, infrastructure-as-code, and DevSecOps practices.  
  
I maintain a full homelab environment where I build and test modern infrastructure patterns using:  
- 🖥️ **Proxmox** for virtualization  
- ☸️ **Kubernetes** for orchestration  
- 🛠️ **GitHub Actions** and **GitLab CI/CD** for pipelines  
- 📦 **Docker**, **Terraform**, and **Ansible** for automation and provisioning  
- 📊 **Prometheus**, **Grafana**, **Alertmanager** for monitoring and alerting  
  
I also work with **public cloud providers** — **Azure**, **AWS**, and **Google Cloud** — and showcase workflows and IaC examples for these platforms.  
  
This repository is meant for **employers** to review my skills in action: demonstrating clarity, automation, and security-first design.  
  
# **Showcase Workflows**  
  
This repository contains **sanitized, public-safe examples** of the CI/CD and DevSecOps pipelines I run in my homelab.   
It demonstrates how I structure pipelines, enforce security scanning, and integrate Infrastructure-as-Code checks — without exposing real secrets or infrastructure.  
⸻  
## **🚀 Workflows**  
  
### **Continuous Integration (CI)**  
[Showcase CI](https://github.com/chadalanlester/showcase/actions/workflows/ci.yml)  
  
The **CI pipeline** runs automatically on pushes, pull requests, or manual dispatch.   
It demonstrates a full multi-stage process:  
  
- **Linting**  
    - YAML lint (==yamllint==)  
- **Infrastructure-as-Code (IaC)**  
    - Terraform ==init== + ==plan==  
- **Security scanning**  
    - Trivy filesystem scan  
    - tfsec Terraform security analysis  
- **Software Bill of Materials (SBOM)**  
    - Syft generates SPDX JSON artifact  
  
### **Security Scans**  
[Security Scans](https://github.com/chadalanlester/showcase/actions/workflows/security.yml)  
  
The **Security workflow** provides a focused DevSecOps example:  
- **Trivy** for vulnerability/misconfiguration scanning  
- **tfsec** for Terraform static analysis  
- **Syft** for SBOM generation and artifact upload  
⸻  
## **🛡️ Security & Compliance**  
  
- All scans run in **Docker containers**, no host dependencies.  
- **No secrets required** — workflows run safely in public without exposing credentials.  
- **SBOM artifacts** are generated and uploaded for transparency.  
⸻  
## **💡 Key Practices Demonstrated**  
  
- ✅ Multi-stage CI/CD with dependencies  
- ✅ Infrastructure-as-Code validation (Terraform)  
- ✅ Security scanning with Trivy, tfsec  
- ✅ SBOM generation (Syft)  
- ✅ Style compliance with yamllint  
- ✅ GitHub Actions badges for instant visibility  
⸻  
🧰**** Technologies × Workflows****  

| Technology / Tool | Showcase CI | Security Scans |
| --------------------- | ---------------------------------- | ---------------------- |
| YAML Lint (yamllint) | ✅ | ❌ |
| Terraform (init/plan) | ✅ | ✅ (scanned with tfsec) |
| Ansible | Demo playbook included | ❌ |
| Trivy | ✅ (filesystem scan) | ✅ (filesystem scan) |
| tfsec | ✅ | ✅ |
| Syft (SBOM) | ✅ | ✅ |
| Docker | ✅ (all jobs run via Docker images) | ✅ |
| GitHub Actions | ✅ | ✅ |
  
  
✅ = tool is actively used in that workflow   
❌ = not applicable  
⸻  
## **📝 Notes**  
  
- **Terraform** → Uses only ==null_resource== → safe and non-destructive.  
- **Ansible** → Playbook contains a simple ==debug== message → illustrates CI integration, but does not target real hosts.  
- **Badges** → Reflect the current status of CI and security scans on the ==main== branch.  
⸻  
## **👀 For Employers**  
  
This repository is a **showcase of my skills as an SRE**.   
It demonstrates:  
  
- My ability to design and implement structured pipelines  
- A strong focus on **automation, security, and maintainability**  
- Hands-on experience across **on-prem (homelab)** and **cloud platforms (Azure, AWS, GCP)**  
- **Kubernetes expertise**: GitOps with Argo CD, Helm, Prometheus/Grafana monitoring, RBAC governance  
- Clear **coding and documentation standards**: consistent style, linting, evidence-driven workflows  
- A professional, transparent way of documenting and presenting technical work  
⸻  
# **🚀 SRE Showcase – Multi-Cloud & Resilience Projects**  
  
This repository demonstrates **Site Reliability Engineering (SRE)** practices across multiple clouds (AWS, Azure, GCP), GitOps (Argo CD, FluxCD), observability (Prometheus & Grafana), security controls, and resilience testing.  
  
Each project is structured with:  
- 📂 Infrastructure-as-Code (Terraform, Ansible, Helm)  
- 🔐 Security & compliance scans (tfsec, Trivy, RBAC policies)  
- 📊 Monitoring & evidence capture  
- 📜 Documentation & GitOps-style workflows  
⸻  
## **🌍 Project 1: Multi-Cloud GitOps with Argo CD**  
  
**Goal:** Deploy and manage workloads on **AWS EKS** and **GCP GKE** clusters using Argo CD GitOps.  
  
**Key Features**  
- Terraform to provision:  
    - AWS EKS in ==us-west-1==  
    - GCP GKE in ==us-central1-a==  
- Argo CD App-of-Apps pattern for GitOps sync  
- Monitoring stack: Prometheus, Grafana, Alertmanager  
  
**Evidence**  
- ✅ Hello app deployed to both EKS and GKE  
- ✅ Grafana exposed via LoadBalancer  
- ✅ Prometheus CRDs installed  
  
📄 See: [project-1-multicloud-gitops](./project-1-multicloud-gitops)  
⸻  
## **🏗️ Project 2: Case Platform (Vendor-Scrubbed)**  
  
**Goal:** Adapt a previous interview technical exercise into a neutral, public-safe SRE project.  
  
**Key Features**  
- AWS VPC + EC2 with Terraform  
- Security groups + monitoring  
- CloudWatch alarms  
- Cleaned of vendor references  
  
**Evidence**  
- ✅ EC2 bootstrapped with demo app  
- ✅ Security groups + CloudWatch monitoring  
  
📄 See: [project-2-case-platform](./project-2-case-platform)  
⸻  
## **🌐 Project 3: Multi-Cloud GitOps (EKS + GKE)**  
  
**Goal:** Deploy workloads consistently across AWS EKS and GCP GKE using Argo CD.  
  
**Key Features**  
- IaC for AWS + GCP clusters  
- Argo CD App-of-Apps pattern  
- Monitoring stack (Prometheus + Grafana)  
- Scripts for kubeconfig switching  
  
**Evidence**  
- ✅ Hello demo app running in both clouds  
- ✅ Observability dashboards up  
  
📄 See: [project-1-multicloud-gitops](./project-1-multicloud-gitops)  
⸻  
## **🛡️ Project 4: Resilient Web Application with Self-Healing**  
  
**Goal:** Showcase Kubernetes **self-healing, autoscaling, and chaos testing** with a Flask trivia API.  
  
**Key Features**  
- Kubernetes Deployment with readiness/liveness probes  
- HPA, PDBs, autoscaling  
- Chaos testing scripts (kill pods, load gen, restart remediation)  
- Prometheus SLO validation  
  
**Evidence**  
- ✅ Pods recover after chaos tests  
- ✅ Autoscaling under load  
- ✅ Prometheus metrics validated  
  
📄 See: [project-4-resilient-app](./project-4-resilient-app)  
⸻  
## **📦 ## Project 5 – AWS CloudFormation SRE Showcase**  
##   
## **This project demonstrates how to provision and operate a resilient AWS workload using **CloudFormation**, **Lambda**, **CloudWatch**, and **SNS** — all within the AWS Free Tier.  **  
## **It showcases **Site Reliability Engineering (SRE) practices** such as automated health checks, alerting, and self-healing.**  
##   
## **---**  
##   
## **### **🚀** Problem Statement**  
## **Modern SREs need more than manual runbooks — they need **infrastructure as code**, automated monitoring, and **auto-remediation** to maintain service reliability with minimal human intervention.  **  
## **This project explores how to implement those principles in AWS, reproducibly and cost-effectively.**  
##   
## **---**  
##   
## **### **🛠️** Solution**  
## **- **CloudFormation (IaC):**  **  
## **  Provisions the entire environment — EC2 instance, IAM roles, CloudWatch alarms, Lambda, and SNS topic — in a single reproducible template.**  
## **- **EC2 Web Server:**  **  
## **  A minimal nginx instance, used as the workload under test.**  
## **- **Lambda Healthcheck:**  **  
## **  Periodically checks the instance’s EC2/system status *and* HTTP response.  **  
## **  - Publishes findings to SNS.  **  
## **  - Auto-remediates by rebooting the instance if checks fail.**  
## **- **CloudWatch Alarms:**  **  
## **  - CPU utilization threshold.  **  
## **  - Status check failures.  **  
## **- **SNS Notifications:**  **  
## **  Sends alerts via email to the on-call SRE (configured during deployment).**  
## **- **Pre-commit + CI Linting:**  **  
## **  Enforces YAML, CloudFormation, and Python quality gates both locally and in GitHub Actions.**  
##   
## **---**  
##   
## **### **✅** Verification Evidence**  
## **Key runtime checks performed during deployment:**  
##   
## **- Stack: `project-5-AWS-CloudFormation` in `us-east-1`**  
## **- Instance: Provisioned EC2 with public IP**  
## **- SNS Topic: Verified email subscription**  
##   
## **```bash**  
## **# Health check over HTTP**  
## **curl -I http://<EC2_IP>/**  
##   
## **# Lambda on-demand check**  
## **aws lambda invoke --function-name project-5-AWS_CloudFormation-healthcheck \**  
## **  --region us-east-1 /dev/stdout | jq .**  
##   
## **# Alarms present**  
## **aws cloudformation list-stack-resources \**  
## **  --stack-name project-5-AWS-CloudFormation --region us-east-1 \**  
## **  --query "StackResourceSummaries[?ResourceType=='AWS::CloudWatch::Alarm'].[LogicalResourceId,PhysicalResourceId]" \**  
## **  --output table**  
##   
## **# SNS test**  
## **aws sns publish --region us-east-1 \**  
## **  --topic-arn <TOPIC_ARN> \**  
## **  --subject "SNS test" --message "OK"**  
  
**---**  
  
**### **🧹** Teardown / Cost Control**  
**All resources can be safely deleted with:**  
  
**```bash**  
**aws cloudformation delete-stack --stack-name project-5-AWS-CloudFormation --region us-east-1**  
  
Additional cleanup steps:  
	•	**EC2 Key Pair:** Delete the key pair in AWS and securely remove the local .pem file.  
	•	**Lambda Logs:** Delete the /aws/lambda/project-5-AWS_CloudFormation-healthcheck log group.  
	•	**Lambda Logs:** Delete the /aws/lambda/project-5-AWS_CloudFormation-healthcheck log group.  
	•	**SSH Cleanup:** Remove the EC2 IP entry from ~/.ssh/known_hosts.  
	•	**SSH Cleanup:** Remove the EC2 IP entry from ~/.ssh/known_hosts.  
	•	**CloudWatch/SNS Audit:** Confirm no orphaned alarms or topics remain.  
  
⸻  
  
📚** Lessons Learned**  
	•	CloudFormation templates require exact alignment between the **Lambda handler** (index.lambda_handler) and the deployed Python code.  
	•	**Pre-commit hooks** (yamllint, cfn-lint, flake8) helped enforce quality, but intrinsic functions (!Ref, !Sub) required YAML exclusions.  
	•	set-alarm-state is useful for testing CloudWatch alarms, but names must exactly match deployed resources.  
	•	**Cleanup discipline** (stack deletion, key removal, log cleanup) is essential to avoid hidden AWS charges.  
	•	**Cleanup discipline** (stack deletion, key removal, log cleanup) is essential to avoid hidden AWS charges.  
  
⸻  
  
🌟** Key Takeaway**  
  
This project demonstrates **end-to-end SRE practices**:  
	•	Infrastructure as Code (CloudFormation)  
	•	Monitoring and alerting (CloudWatch + SNS)  
	•	Automated remediation (Lambda healthcheck + EC2 reboot)  
	•	CI/CD and quality gates (pre-commit, GitHub Actions)  
  
All implemented reproducibly and cost-effectively within the **AWS Free Tier**.  
⸻  
## **☸️ Project 6: Azure AKS GitOps**  
  
**Goal:** Deploy a production-style **AKS (Azure Kubernetes Service)** cluster with **GitOps**, observability, and secure supply chain integrations — while staying within free-tier limits.  
  
### **Key Features**  
- Terraform + GitHub Actions deploy AKS with:  
    - System pool (B2ms) and workload pool (B2ms)  
    - Azure RBAC enabled with minimal cluster role bindings  
    - ACR integration (==AcrPull== role assignment)  
    - Key Vault CSI driver integration (future-ready)  
- Monitoring stack via Helm:  
    - Prometheus, Alertmanager, Grafana exposed via LoadBalancer  
    - Default-deny NetworkPolicy  
- Evidence captured under ==project-6-azure-aks-gitops/evidence/==  
  
### **Evidence**  
- ==project-6-azure-aks-gitops/evidence/*/nodes.txt==  
- ==project-6-azure-aks-gitops/evidence/*/monitoring-pods.txt==  
- ==project-6-azure-aks-gitops/evidence/*/monitoring-svc.txt==  
  
### **SRE Mapping**  
- **GitOps & Change Control:** Terraform plans in CI; Helm releases recorded  
- **Observability:** Prometheus + Grafana + Alertmanager; LB dashboards  
- **Secure Supply Chain:** ACR AcrPull, OIDC auth, KV CSI-ready  
- **RBAC & Governance:** Azure RBAC + minimal in-cluster binding; Policy add-on  
- **Folder:** ==project-6-azure-aks-gitops==  
⸻  
## **🏛️ Project 7: Azure HA Web on Hub-Spoke + VMSS**  
  
**Goal:** Build a **high-availability web service** in Azure using **Hub-Spoke networking** and **VM Scale Sets**.  
  
**Key Features**  
- Hub-Spoke VNET with firewalls  
- VM Scale Set running NGINX  
- Application Gateway health checks  
- Evidence of backend health + scaling  
  
**Evidence**  
- ✅ AppGW backend probe screenshots  
- ✅ VMSS scaling observed  
- ✅ Curl health checks saved in repo  
  
📄 See: [project-7-azure-ha-web](./project-7-azure-ha-web)  
⸻  
⸻  
  
  
## **🧹 Project 8: Cleanup & Cost Control**  
  
**Goal:** Ensure all showcase projects remain cost-efficient and do not accumulate unnecessary charges across Azure, AWS, or GCP.  
  
### **Key Practices**  
- **Terraform destroy** workflows included to safely tear down infra  
- **Azure cleanup scripts**:  
    - Delete AKS clusters and node resource groups  
    - Remove ACRs, Key Vaults, Log Analytics Workspaces  
    - Respect Key Vault soft-delete protections  
- **AWS & GCP cleanup**:  
    - Destroy EKS and GKE clusters after demos  
    - Remove load balancers, IPs, and disks tied to projects  
- **Monitoring**:  
    - Evidence captured before teardown for audit trail  
    - Prometheus/Grafana dashboards exported before delete  
  
### **SRE Mapping**  
- **Cost Awareness:** Uses free-tier SKUs (e.g., B2ms in Azure AKS)  
- **Governance:** Enforces teardown after each demo project  
- **Auditability:** Evidence folders prove deployments before cleanup  
- **Resilience in Practice:** Demonstrates lifecycle of build → validate → destroy  
⸻  

## 🚀 Project 9: AWS AI Feedback Triage

**Status:** Completed (tag: `v1.0.1`)  
**Repo:** [project-9-aws-ai-feedback-triage](./project-9-aws-ai-feedback-triage)  

This project implements an **end-to-end serverless system on AWS** for ingesting, analyzing, and triaging customer feedback in real time.

### 🔹 Key Features
- **Serverless ingestion** via **API Gateway** and **S3 batch uploads**
- **Natural Language Processing** with **Amazon Comprehend**  
  - Sentiment detection (positive/negative/neutral/mixed)  
  - Entity and key phrase extraction  
- **Storage & persistence** with **Amazon DynamoDB**
- **Alerts & monitoring**  
  - **SNS email alerts** on negative sentiment or pipeline errors  
  - **CloudWatch Alarms & Dashboard** for unified observability
- **Infrastructure-as-Code** with **Terraform**  
  - Parameterized, reusable modules  
  - One-command deploy/destroy (`make deploy`, `terraform destroy`)  
  - `.gitignore` + `git filter-repo` used to keep TF state/build artifacts clean

### 📸 Screenshots & Diagrams
- [Architecture Diagram](./project-9-aws-ai-feedback-triage/docs/architecture.png)  
- [Setup & Walkthrough](./project-9-aws-ai-feedback-triage/docs/README.md)  

### 🛠️ Tech Stack
- **AWS Lambda (Python 3.12)**  
- **Amazon API Gateway (HTTP API)**  
- **Amazon S3**  
- **Amazon Comprehend**  
- **Amazon DynamoDB**  
- **Amazon SNS**  
- **Amazon CloudWatch (Dashboard + Alarms)**  
- **Terraform** (modular IaC)  

👉 This project demonstrates a **production-grade reference architecture** for **real-time AI-driven feedback triage**. It’s directly applicable to **customer support automation, feedback loops, or monitoring pipelines** where **serverless + NLP** can reduce manual effort.  

⸻
## **📫 Contact**  
  
I maintain this repository as part of my professional portfolio.   
If you’d like to connect or discuss opportunities:  
  
- **LinkedIn**: [linkedin.com/in/chadalanlester](https://www.linkedin.com/in/chadalanlester)  
- **GitHub**: [github.com/chadalanlester](https://github.com/chadalanlester)  
- **Email**: [chad@chadlester.com](mailto:chad@chadlester.com)  
  
Always happy to talk about **SRE, DevSecOps, Kubernetes, automation, and resilient systems**.  
⸻  
## **✅ Final Notes**  
  
This repository demonstrates my **end-to-end approach as an SRE**:  
  
- 🔹 Infrastructure-as-Code with **Terraform** and **Ansible**  
- 🔹 **Kubernetes-first design** with GitOps, monitoring, and self-healing  
- 🔹 Strong **DevSecOps practices** with CI/CD, security scans, and RBAC  
- 🔹 Commitment to **coding standards, documentation, and evidence-based delivery**  
- 🔹 Focus on **resilience, observability, and cost control** — critical in real-world production  
  
Future projects will expand into advanced topics such as **multi-region failover, compliance automation, and AI-assisted incident response**.  
  
This repo is designed for employers, peers, and collaborators to **see real, working examples of enterprise-grade SRE practices**.  
