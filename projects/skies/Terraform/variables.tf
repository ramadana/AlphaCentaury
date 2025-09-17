# variables.tf
variable "vultr_api_key" {
  description = "Vultr API key"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for your domain"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the load balancer"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for accessing instances"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "kubernetes_version" {
  description = "Kubernetes version for VKE clusters"
  type        = string
  default     = "v1.28.2+1"
}

variable "node_plans" {
  description = "Vultr plans for each node type"
  type = object({
    luminaire = string
    thera     = string
    jita      = string
    umbra     = string
    perimeter = string
  })
  default = {
    luminaire = "vc2-2c-4gb"  # 2 vCPU, 4GB RAM for monitoring stack
    thera     = "vc2-4c-8gb"  # 4 vCPU, 8GB RAM for databases
    jita      = "vc2-4c-8gb"  # 4 vCPU, 8GB RAM for backends + Kafka
    umbra     = "vc2-2c-4gb"  # 2 vCPU, 4GB RAM for frontends
    perimeter = "vc2-2c-4gb"  # 2 vCPU, 4GB RAM for API Gateway
  }
}

variable "vps_plans" {
  description = "Vultr plans for VPS instances"
  type = object({
    stargate  = string
    ethernity = string
  })
  default = {
    stargate  = "vc2-1c-2gb"  # 1 vCPU, 2GB RAM for bastion
    ethernity = "vc2-4c-8gb"  # 4 vCPU, 8GB RAM for GitHub runners
  }
}