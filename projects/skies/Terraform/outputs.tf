output "cluster_id" {
  description = "VKE cluster ID"
  value       = vultr_kubernetes.skies_nrt.id
}

output "cluster_endpoint" {
  description = "VKE cluster API endpoint"
  value       = vultr_kubernetes.skies_nrt.endpoint
}

output "cluster_ip" {
  description = "VKE cluster IP address"
  value       = vultr_kubernetes.skies_nrt.ip
}

output "cluster_subnet" {
  description = "VPC subnet CIDR for the cluster"
  value       = format("%s/%d", data.vultr_vpc.nrt_skies.v4_subnet, data.vultr_vpc.nrt_skies.v4_subnet_mask)
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = vultr_kubernetes.skies_nrt.version
}

output "kube_config" {
  description = "Kubeconfig for accessing the cluster (if available)"
  value       = try(vultr_kubernetes.skies_nrt.kube_config, null)
  sensitive   = true
}

output "node_pool_alikara" {
  description = "Information about alikara node pool (inline with cluster)"
  value       = vultr_kubernetes.skies_nrt.node_pools
}

output "node_pool_sobaseki_id" {
  description = "ID of sobaseki node pool"
  value       = vultr_kubernetes_node_pools.sobaseki.id
}

output "firewall_group_id" {
  description = "Auto-generated firewall group ID for the cluster"
  value       = vultr_kubernetes.skies_nrt.firewall_group_id
}
