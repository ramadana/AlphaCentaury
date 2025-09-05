variable "vultr_api_key" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  description = "Public key to inject into all instances"
  type        = string
}

# cluster specification
variable "clusters" {
  type = map(object({
    region         = string
    vpc_cidr       = string
    label          = string
    control_plane  = string
    nodes = map(object({
      plan     = string
      hostname = string
      os_id    = number
      tags     = list(string)
    }))
  }))
}