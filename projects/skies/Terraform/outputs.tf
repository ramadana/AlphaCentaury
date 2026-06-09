output "cluster_id" {
  description = "VKE cluster ID for skies-noc"
  value       = vultr_kubernetes.skies_noc.id
}

output "cluster_label" {
  description = "VKE cluster label"
  value       = vultr_kubernetes.skies_noc.label
}

output "cluster_endpoint" {
  description = "VKE cluster API endpoint"
  value       = vultr_kubernetes.skies_noc.endpoint
}

output "cluster_ip" {
  description = "VKE cluster public IP"
  value       = vultr_kubernetes.skies_noc.ip
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = vultr_kubernetes.skies_noc.version
}

output "cluster_region" {
  description = "Vultr region"
  value       = vultr_kubernetes.skies_noc.region
}

output "vpc_id" {
  description = "VPC ID used by the cluster"
  value       = local.vpc_id
}

output "vpc_subnet" {
  description = "VPC subnet CIDR"
  value = var.create_vpc ? format(
    "%s/%d",
    vultr_vpc.skies_noc[0].v4_subnet,
    vultr_vpc.skies_noc[0].v4_subnet_mask,
  ) : null
}

output "kube_config" {
  description = "Kubeconfig for accessing skies-noc"
  value       = try(vultr_kubernetes.skies_noc.kube_config, null)
  sensitive   = true
}

output "node_pools" {
  description = "Node pool summary"
  value = merge(
    {
      arnon = {
        id         = vultr_kubernetes.skies_noc.node_pools[0].id
        label      = vultr_kubernetes.skies_noc.node_pools[0].label
        plan       = vultr_kubernetes.skies_noc.node_pools[0].plan
        node_count = vultr_kubernetes.skies_noc.node_pools[0].node_quantity
        workloads  = "Nginx/APISIX ingress, Loki, Bastion"
      }
    },
    {
      for name, pool in vultr_kubernetes_node_pools.additional : name => {
        id         = pool.id
        label      = pool.label
        plan       = pool.plan
        node_count = pool.node_quantity
        workloads = lookup({
          yulai = "Metabase, Grafana, PostgreSQL"
          thera = "Prometheus, GitHub Actions runners"
        }, name, "—")
      }
    }
  )
}

output "firewall_group_id" {
  description = "Auto-generated firewall group ID for skies-noc"
  value       = vultr_kubernetes.skies_noc.firewall_group_id
}
