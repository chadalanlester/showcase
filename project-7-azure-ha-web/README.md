# ======================================================================
# FILE: README.md
# ======================================================================
# Project 7 — Azure HA Web on Hub-Spoke + VMSS (Terraform + Ansible + CI)
#
# What you get
# - Hub-Spoke Azure landing zone: Hub VNet with Azure Firewall + Bastion; Spoke VNet for apps
# - App Gateway WAF v2 with autoscale, public IP, OWASP 3.2, HTTP listener (80)
# - Linux VM Scale Set (Ubuntu 22.04) in spoke; cloud-init installs NGINX
# - Log Analytics workspace; Azure Monitor Agent on VMSS; Diagnostic Settings on AGW/Firewall/Bastion
# - Route tables force egress through Azure Firewall (0.0.0.0/0)
# - GitHub Actions to fmt/validate/plan/apply Terraform
# - Ansible job to push content updates via VMSS Custom Script Extension (no SSH exposure)
#
# Why it matters (SRE framing)
# - HA: App Gateway v2 autoscale + VMSS zonal spread (if available) + stateless web tier
# - Security: Hub-Spoke isolation, firewall egress, private subnets, Bastion for admin, WAF in front
# - Monitoring: AMA + Log Analytics + diagnostic settings on control plane
# - IR readiness: WAF logs, Firewall logs, VMSS agent; infra-as-code for rapid rebuilds
#
# Compliance mapping (starter)
# - NIST 800-53: AC-17 (Bastion), AU-2/6 (logging), SC-7 (firewall), SI-4 (monitoring)
# - FedRAMP: Audit/logs centralized; boundary protection; change control via GitOps
# - HIPAA/GDPR: Not PHI/PII here, but patterns support network segmentation + logging + least access
#
# Prereqs (Mac)
#   brew install azure-cli terraform ansible git jq
#   az login
#   az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
#
# Repo layout
#   project7-azure-ha-web/
#   ├── terraform/
#   │   ├── providers.tf
#   │   ├── variables.tf
#   │   ├── outputs.tf
#   │   ├── main.tf
#   │   ├── cloud-init/
#   │   │   └── web.yaml
#   │   ├── backend.hcl.example
#   │   └── tfvars.example
#   ├── ansible/
#   │   ├── collections/requirements.yml
#   │   ├── playbooks/site.yml
#   │   └── group_vars/all.yml
#   ├── .github/workflows/ci-terraform.yml
#   ├── scripts/bootstrap-state.sh
#   └── README.md
#
# Usage (Mac)
# 1) mkdir -p ~/Projects/Showcase && cd ~/Projects/Showcase
# 2) git clone <your-empty-repo-url> project7-azure-ha-web && cd project7-azure-ha-web
# 3) Put these files in place (exact paths). Then:
#    git add . && git commit -m "🌐 Project7: hub-spoke + VMSS + AppGW WAF + logging (initial)"
#    git push origin main
#
# 4) (One-time) create remote TF state in Azure (Mac):
#    ./scripts/bootstrap-state.sh "<UNIQUE_NAME>" "<RESOURCE_GROUP_LOCATION>"
#    # Example: ./scripts/bootstrap-state.sh p7state eastus
#
# 5) Prepare Terraform vars (Mac):
#    cd terraform
#    cp tfvars.example terraform.tfvars
#    # Edit terraform.tfvars values; export your SSH key:
#    export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
#
# 6) Terraform apply (Mac):
#    terraform init -backend-config=backend.hcl
#    terraform fmt -recursive
#    terraform validate
#    terraform plan -out plan.tfplan
#    terraform apply -auto-approve plan.tfplan
#
# 7) Get URL (Mac):
#    terraform output appgw_public_ip
#    # Open http://<that-ip>/  to see NGINX landing page
#
# 8) Update web content via Ansible (uses VMSS extension, no SSH exposure) (Mac):
#    cd ../ansible
#    python3 -m pip install -r <(printf "ansible-core\nazure-identity\nazure-mgmt-compute\n") 2>/dev/null || true
#    ansible-galaxy collection install -r collections/requirements.yml
#    # Export Azure creds for Ansible:
#    export AZURE_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
#    # If using a Service Principal:
#    # export AZURE_CLIENT_ID=...
#    # export AZURE_CLIENT_SECRET=...
#    # export AZURE_TENANT=...
#    ansible-playbook playbooks/site.yml -e "content_version=$(date +%s)"
#
# 9) GitOps discipline (Mac):
#    git add -A
#    git commit -m "🚀 Apply: infra changes + content update"
#    git push
#
# 10) Destroy when done (Mac):
#    cd ../terraform
#    terraform destroy
#
# Incident play (quick)
# - Spike 5xx? Check AppGW WAF logs in Log Analytics; validate health probe; scale VMSS if needed
# - Egress blocks? Check Azure Firewall logs; confirm route tables on spoke subnets
# - Host issues? Use Ansible job to roll content change or run a custom script via VMSS extension
