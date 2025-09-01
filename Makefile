TERRAFORM_DIR := terraform

.PHONY: init plan apply destroy output validate fmt bootstrap

init:
	@echo "🔧 Initializing Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

plan:
	@echo "📋 Planning Terraform changes..."
	cd $(TERRAFORM_DIR) && terraform plan -lock=false

apply:
	@echo "🚀 Applying Terraform plan..."
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve -lock=false

destroy:
	@echo "💣 Destroying Terraform-managed infrastructure..."
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve -lock=false

output:
	@echo "🔎 Showing Terraform outputs..."
	cd $(TERRAFORM_DIR) && terraform output

validate:
	@echo "✅ Validating Terraform..."
	cd $(TERRAFORM_DIR) && terraform validate

fmt:
	@echo "🧹 Formatting Terraform code..."
	cd $(TERRAFORM_DIR) && terraform fmt -recursive

bootstrap:
	@echo "📦 Installing Terraform (if needed)..."
	command -v terraform >/dev/null 2>&1 || brew install terraform
