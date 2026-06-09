variable "vultr_api_key" {
  description = "Vultr API key"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (e.g. production, staging)"
  type        = string
  default     = "production"
}

variable "region" {
  description = "Vultr region for skies-noc"
  type        = string
  default     = "sgp"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the VKE cluster"
  type        = string
  default     = "v1.34.1+1"
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

variable "create_vpc" {
  description = "Create a new VPC. Set to false when attaching to an existing VPC via vpc_id."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Existing VPC ID in the target region. Required when create_vpc is false."
  type        = string
  default     = ""

  validation {
    condition     = var.create_vpc || var.vpc_id != ""
    error_message = "vpc_id must be set when create_vpc is false."
  }
}

variable "vpc_description" {
  description = "Description for the VPC when create_vpc is true"
  type        = string
  default     = "SKIES NOC observability cluster VPC (Singapore)"
}

variable "vpc_v4_subnet" {
  description = "IPv4 subnet base when creating a new VPC (e.g. 10.41.0.0)"
  type        = string
  default     = "10.41.0.0"
}

variable "vpc_v4_subnet_mask" {
  description = "IPv4 subnet mask when creating a new VPC"
  type        = number
  default     = 16
}

# ------------------------------------------------------------------------------
# Node pools — skies-noc
# ------------------------------------------------------------------------------

variable "node_pools" {
  description = "Node pool definitions for skies-noc. Keys must include arnon (initial inline pool)."
  type = map(object({
    plan     = string
    quantity = number
  }))

  default = {
    arnon = {
      plan     = "vhp-2c-4gb-amd"
      quantity = 1
    }
    yulai = {
      plan     = "vhp-2c-4gb-amd"
      quantity = 1
    }
    thera = {
      plan     = "vhp-2c-4gb-amd"
      quantity = 1
    }
  }

  validation {
    condition     = contains(keys(var.node_pools), "arnon")
    error_message = "node_pools must include an \"arnon\" entry (initial inline pool for ingress/bastion)."
  }
}

# ------------------------------------------------------------------------------
# Firewall
# ------------------------------------------------------------------------------

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into nodes (bastion management on Arnon)"
  type        = list(string)
  default     = []
}

variable "bastion_allowed_cidrs" {
  description = "CIDR blocks allowed to reach NodePort services for cross-cluster debugging"
  type        = list(string)
  default     = []
}

variable "nodeport_range" {
  description = "NodePort range opened to bastion_allowed_cidrs"
  type        = string
  default     = "31501:31800"
}
