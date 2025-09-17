# modules/cloudflare/outputs.tf

output "load_balancer_id" {
  description = "Cloudflare Load Balancer ID"
  value       = cloudflare_load_balancer.main.id
}

output "load_balancer_hostname" {
  description = "Cloudflare Load Balancer hostname"
  value       = cloudflare_load_balancer.main.name
}

output "pool_id" {
  description = "Origin pool ID"
  value       = cloudflare_load_balancer_pool.main.id
}

output "monitor_id" {
  description = "Health check monitor ID"
  value       = cloudflare_load_balancer_monitor.main.id
}

output "pool_health" {
  description = "Pool health status"
  value       = cloudflare_load_balancer_pool.main.enabled
}