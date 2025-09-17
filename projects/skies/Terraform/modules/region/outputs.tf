# modules/region/outputs.tf
output "cluster_id" {
  description = "VKE cluster ID"
  value       = vultr_kubernetes.cluster.id
}

output "cluster_endpoint" {
  description = "VKE cluster endpoint"
  value       = vultr_kubernetes.cluster.endpoint
}

output "cluster_ip" {
  description = "VKE cluster IP"
  value       = vultr_kubernetes.cluster.ip
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = vultr_kubernetes.cluster.kube_config
  sensitive   = true
}

output "vps_instances" {
  description = "VPS instance information"
  value = {
    for k, v in vultr_instance.vps : k => {
      id          = v.id
      main_ip     = v.main_ip
      internal_ip = v.internal_ip
      hostname    = v.hostname
      label       = v.label
    }
  }
}

output "node_pools" {
  description = "Node pool information"
  value = {
    for pool in vultr_kubernetes.cluster.node_pools : pool.label => {
      id           = pool.id
      node_quantity = pool.node_quantity
      plan         = pool.plan
      tag          = pool.tag
    }
  }
}