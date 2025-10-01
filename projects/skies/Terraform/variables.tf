variable "vultr_api_key" {
  description = "Vultr API key"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "kubernetes_version" {
  description = "Kubernetes version for VKE cluster"
  type        = string
  default     = "v1.34.1+1"
}
