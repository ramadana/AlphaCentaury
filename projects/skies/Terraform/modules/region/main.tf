# modules/region/main.tf
terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
}

# VKE Cluster
resource "vultr_kubernetes" "cluster" {
  region  = var.region_id
  label   = var.cluster_name
  version = var.vke_version
  
  dynamic "node_pools" {
    for_each = var.nodes
    content {
      node_quantity = node_pools.value.node_count
      plan          = node_pools.value.plan
      label         = node_pools.value.label
      auto_scaler   = node_pools.value.auto_scaler
      min_nodes     = node_pools.value.min_nodes
      max_nodes     = node_pools.value.max_nodes
      tag           = node_pools.key
    }
  }
}

# VPS Instances
resource "vultr_instance" "vps" {
  for_each = var.vps_instances
  
  region   = var.region_id
  plan     = each.value.plan
  os_id    = var.os_id
  label    = each.value.label
  hostname = each.value.hostname
  
  ssh_key_ids = var.ssh_key_ids
  
  # Cloud-init script for basic setup
  user_data = base64encode(templatefile("${path.module}/templates/cloud-init.yml", {
    hostname = each.value.hostname
    instance_type = each.key
  }))
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
  
  tags = merge(var.tags, {
    Name = each.value.label
    Type = each.key
  })
}

# Firewall for VPS instances
resource "vultr_firewall_group" "vps" {
  count       = length(var.vps_instances) > 0 ? 1 : 0
  description = "Firewall for VPS instances in ${var.region_code}"
}

resource "vultr_firewall_rule" "ssh" {
  count            = length(var.vps_instances) > 0 ? 1 : 0
  firewall_group_id = vultr_firewall_group.vps[0].id
  protocol         = "tcp"
  ip_type          = "v4"
  subnet           = "0.0.0.0"
  subnet_size      = 0
  port             = "22"
  notes           = "SSH access"
}

resource "vultr_firewall_rule" "http" {
  count            = length(var.vps_instances) > 0 ? 1 : 0
  firewall_group_id = vultr_firewall_group.vps[0].id
  protocol         = "tcp"
  ip_type          = "v4"
  subnet           = "0.0.0.0"
  subnet_size      = 0
  port             = "80"
  notes           = "HTTP access"
}

resource "vultr_firewall_rule" "https" {
  count            = length(var.vps_instances) > 0 ? 1 : 0
  firewall_group_id = vultr_firewall_group.vps[0].id
  protocol         = "tcp"
  ip_type          = "v4"
  subnet           = "0.0.0.0"
  subnet_size      = 0
  port             = "443"
  notes           = "HTTPS access"
}

resource "vultr_firewall_rule" "github_runner" {
  count            = contains(keys(var.vps_instances), "ethernity") ? 1 : 0
  firewall_group_id = vultr_firewall_group.vps[0].id
  protocol         = "tcp"
  ip_type          = "v4"
  subnet           = "0.0.0.0"
  subnet_size      = 0
  port             = "8080"
  notes           = "GitHub Runner webhook"
}

# Apply firewall to VPS instances
resource "vultr_firewall_group_instance" "vps" {
  for_each = var.vps_instances
  
  firewall_group_id = vultr_firewall_group.vps[0].id
  instance_id       = vultr_instance.vps[each.key].id
}