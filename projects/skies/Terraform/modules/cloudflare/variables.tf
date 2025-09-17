# modules/cloudflare/variables.tf
variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = null
}

variable "origins" {
  description = "Load balancer origins"
  type = map(object({
    name    = string
    address = string
    enabled = bool
    weight  = number
  }))
}

variable "health_check" {
  description = "Health check configuration"
  type = object({
    enabled        = bool
    path          = string
    interval      = number
    retries       = number
    timeout       = number
    method        = string
    expected_codes = string
  })
}

variable "pool_name" {
  description = "Name for the origin pool"
  type        = string
}

variable "load_balancer_name" {
  description = "Name for the load balancer"
  type        = string
}

variable "notification_email" {
  description = "Email for health check notifications"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}