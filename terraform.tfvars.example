# terraform.tfvars.example
# Copy this to terraform.tfvars and fill in your values

# API Keys (keep these secure!)
vultr_api_key         = "your_vultr_api_key_here"
cloudflare_api_token  = "your_cloudflare_api_token_here"

# Cloudflare Configuration
cloudflare_zone_id = "your_cloudflare_zone_id"
domain_name       = "skies.yourdomain.com"

# SSH Configuration
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... your_public_key_here"

# Environment
environment = "production"

# Kubernetes Version (check Vultr for latest supported versions)
kubernetes_version = "v1.28.2+1"

# Node Plans (adjust based on your needs and budget)
node_plans = {
  luminaire = "vc2-2c-4gb"  # Monitoring stack - 2 vCPU, 4GB RAM
  thera     = "vc2-4c-8gb"  # Database node - 4 vCPU, 8GB RAM
  jita      = "vc2-4c-8gb"  # Backend + Kafka - 4 vCPU, 8GB RAM
  umbra     = "vc2-2c-4gb"  # Frontend node - 2 vCPU, 4GB RAM
  perimeter = "vc2-2c-4gb"  # API Gateway - 2 vCPU, 4GB RAM
}

# VPS Plans
vps_plans = {
  stargate  = "vc2-1c-2gb"  # Bastion host - 1 vCPU, 2GB RAM
  ethernity = "vc2-4c-8gb"  # GitHub runners - 4 vCPU, 8GB RAM
}