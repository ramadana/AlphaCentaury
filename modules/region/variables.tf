# modules/region/variables.tf
variable "region_code" {
  description = "Region code (sgp, nrt)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "region_id" {
  description = "Vultr region ID"
  type        = string
}

variable "os_id" {
  description = "Vultr OS ID for Flatcar Container Linux"
  type        = string
}

variable "vke_version" {
  description = "Kubernetes version for VKE"
  type        = string
}

variable "nodes" {
  description = "Node pool configurations"
  type = map(object({
    plan        = string
    label       = string
    auto_scaler = bool
    min_nodes   = number
    max_nodes   = number
    node_count  = number
  }))
}

variable "vps_instances" {
  description = "VPS instance configurations"
  type = map(object({
    plan     = string
    label    = string
    hostname = string
  }))
  default = {}
}

variable "ssh_key_ids" {
  description = "List of SSH key IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}