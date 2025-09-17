# outputs.tf

# Singapore Cluster Outputs
output "singapore_cluster_id" {
  description = "Singapore VKE cluster ID"
  value       = module.singapore.cluster_id
}

output "singapore_cluster_endpoint" {
  description = "Singapore VKE cluster endpoint"
  value       = module.singapore.cluster_endpoint
}

output "singapore_cluster_ip" {
  description = "Singapore VKE cluster IP"
  value       = module.singapore.cluster_ip
}

# Tokyo Cluster Outputs
output "tokyo_cluster_id" {
  description = "Tokyo VKE cluster ID"
  value       = module.tokyo.cluster_id
}

output "tokyo_cluster_endpoint" {
  description = "Tokyo VKE cluster endpoint"
  value       = module.tokyo.cluster_endpoint
}

output "tokyo_cluster_ip" {
  description = "Tokyo VKE cluster IP"
  value       = module.tokyo.cluster_ip
}

# VPS Instance Outputs
output "singapore_vps_instances" {
  description = "Singapore VPS instances"
  value       = module.singapore.vps_instances
}

# Node Pool Information
output "singapore_node_pools" {
  description = "Singapore node pools"
  value       = module.singapore.node_pools
}

output "tokyo_node_pools" {
  description = "Tokyo node pools"
  value       = module.tokyo.node_pools
}

# Kubeconfig files (sensitive)
output "singapore_kubeconfig" {
  description = "Singapore cluster kubeconfig"
  value       = module.singapore.kubeconfig
  sensitive   = true
}

output "tokyo_kubeconfig" {
  description = "Tokyo cluster kubeconfig"
  value       = module.tokyo.kubeconfig
  sensitive   = true
}

# Load Balancer Information
output "cloudflare_load_balancer_id" {
  description = "Cloudflare Load Balancer ID"
  value       = module.cloudflare_lb.load_balancer_id
}

output "cloudflare_pool_id" {
  description = "Cloudflare Origin Pool ID"
  value       = module.cloudflare_lb.pool_id
}

# Summary Information
output "infrastructure_summary" {
  description = "Infrastructure deployment summary"
  value = {
    singapore = {
      cluster_endpoint = module.singapore.cluster_endpoint
      vps_instances   = module.singapore.vps_instances
    }
    tokyo = {
      cluster_endpoint = module.tokyo.cluster_endpoint
    }
    domain = var.domain_name
  }
}