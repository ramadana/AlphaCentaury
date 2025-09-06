# modules/cloudflare/main.tf
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Origin Pool
resource "cloudflare_load_balancer_pool" "main" {
  account_id = var.account_id
  name       = var.pool_name
  
  dynamic "origins" {
    for_each = var.origins
    content {
      name    = origins.value.name
      address = origins.value.address
      enabled = origins.value.enabled
      weight  = origins.value.weight
    }
  }
  
  enabled = true
  
  # Health check monitor
  monitor = cloudflare_load_balancer_monitor.main.id
  
  # Notification settings
  notification_email = var.notification_email
}

# Health Check Monitor
resource "cloudflare_load_balancer_monitor" "main" {
  account_id     = var.account_id
  type           = "https"
  expected_codes = var.health_check.expected_codes
  method         = var.health_check.method
  path           = var.health_check.path
  interval       = var.health_check.interval
  retries        = var.health_check.retries
  timeout        = var.health_check.timeout
  
  description = "Health check for ${var.pool_name}"
}

# Load Balancer
resource "cloudflare_load_balancer" "main" {
  zone_id          = var.zone_id
  name             = var.load_balancer_name
  fallback_pool_id = cloudflare_load_balancer_pool.main.id
  default_pool_ids = [cloudflare_load_balancer_pool.main.id]
  
  description = "Load balancer for Skies infrastructure"
  ttl         = 30
  proxied     = true
  enabled     = true
  
  # Steering policy
  steering_policy = "dynamic_latency"
  
  # Session affinity
  session_affinity = "none"
  
  # Geographic regions (optional)
  region_pools {
    region   = "EEAS" # Eastern Asia
    pool_ids = [cloudflare_load_balancer_pool.main.id]
  }
}