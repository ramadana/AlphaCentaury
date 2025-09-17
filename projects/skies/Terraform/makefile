# Makefile for Skies Infrastructure

.PHONY: help setup init plan apply destroy status clean kubeconfig connect-sgp connect-nrt

# Default target
help: ## Show this help message
	@echo "Skies Infrastructure Management"
	@echo "==============================="
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Run initial setup (install tools, create configs)
	@echo "Running initial setup..."
	@chmod +x setup.sh
	@./setup.sh

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@terraform init

plan: ## Run Terraform plan
	@echo "Running Terraform plan..."
	@terraform plan -out=tfplan

apply: ## Apply Terraform changes
	@echo "Applying Terraform changes..."
	@terraform apply tfplan
	@rm -f tfplan

deploy: init plan apply kubeconfig ## Full deployment: init -> plan -> apply -> extract kubeconfig
	@echo "Deployment completed successfully!"

destroy: ## Destroy all infrastructure
	@echo "WARNING: This will destroy ALL infrastructure!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@terraform destroy

status: ## Check infrastructure status
	@echo "Checking infrastructure status..."
	@chmod +x status.sh
	@./status.sh

clean: ## Clean up temporary files
	@echo "Cleaning up temporary files..."
	@rm -f tfplan
	@rm -f terraform.tfstate.backup
	@rm -f .terraform.lock.hcl.backup

kubeconfig: ## Extract kubeconfig files
	@echo "Extracting kubeconfig files..."
	@chmod +x extract-kubeconfig.sh
	@./extract-kubeconfig.sh

connect-sgp: ## Connect to Singapore cluster
	@echo "Connecting to Singapore cluster..."
	@chmod +x connect-cluster.sh
	@./connect-cluster.sh sgp

connect-nrt: ## Connect to Tokyo cluster  
	@echo "Connecting to Tokyo cluster..."
	@chmod +x connect-cluster.sh
	@./connect-cluster.sh nrt

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@terraform validate

format: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive

lint: validate format ## Run validation and formatting
	@echo "Terraform configuration is valid and formatted!"

output: ## Show Terraform outputs
	@terraform output

cost: ## Estimate infrastructure costs (requires infracost)
	@if command -v infracost >/dev/null 2>&1; then \
		echo "Generating cost estimate..."; \
		infracost breakdown --path .; \
	else \
		echo "Infracost not installed. Install from: https://www.infracost.io/docs/"; \
	fi

docs: ## Generate documentation
	@if command -v terraform-docs >/dev/null 2>&1; then \
		echo "Generating Terraform documentation..."; \
		terraform-docs markdown table . > TERRAFORM_DOCS.md; \
	else \
		echo "terraform-docs not installed. Install from: https://terraform-docs.io/"; \
	fi

ssh-stargate: ## SSH to Stargate bastion host
	@echo "Connecting to Stargate bastion host..."
	@STARGATE_IP=$$(terraform output -json singapore_vps_instances | jq -r '.stargate.main_ip'); \
	ssh -i ~/.ssh/id_rsa core@$$STARGATE_IP

ssh-ethernity: ## SSH to Ethernity GitHub runner host
	@echo "Connecting to Ethernity GitHub runner host..."
	@ETHERNITY_IP=$$(terraform output -json singapore_vps_instances | jq -r '.ethernity.main_ip'); \
	ssh -i ~/.ssh/id_rsa core@$$ETHERNITY_IP

backup-state: ## Backup Terraform state
	@echo "Backing up Terraform state..."
	@cp terraform.tfstate terraform.tfstate.backup.$(shell date +%Y%m%d-%H%M%S)

restore-state: ## Restore Terraform state from backup
	@echo "Available backups:"
	@ls -la terraform.tfstate.backup.* 2>/dev/null || echo "No backups found"
	@read -p "Enter backup filename: " backup; cp $$backup terraform.tfstate

update: ## Update providers and modules
	@echo "Updating Terraform providers and modules..."
	@terraform init -upgrade

check-drift: ## Check for configuration drift
	@echo "Checking for configuration drift..."
	@terraform plan -detailed-exitcode

# Continuous deployment targets
ci-init: ## CI: Initialize Terraform (non-interactive)
	@terraform init -input=false

ci-plan: ## CI: Run Terraform plan (non-interactive)
	@terraform plan -input=false -out=tfplan

ci-apply: ## CI: Apply Terraform changes (non-interactive)
	@terraform apply -input=false tfplan

ci-destroy: ## CI: Destroy infrastructure (non-interactive)
	@terraform destroy -input=false -auto-approve

# Development targets
dev-setup: ## Setup development environment
	@echo "Setting up development environment..."
	@cp terraform.tfvars.example terraform.tfvars
	@echo "Please edit terraform.tfvars with your development values"

prod-setup: ## Setup production environment
	@echo "Setting up production environment..."
	@cp terraform.tfvars.example terraform.tfvars.prod
	@echo "Please edit terraform.tfvars.prod with your production values"

switch-dev: ## Switch to development workspace
	@terraform workspace select dev || terraform workspace new dev

switch-prod: ## Switch to production workspace
	@terraform workspace select prod || terraform workspace new prod