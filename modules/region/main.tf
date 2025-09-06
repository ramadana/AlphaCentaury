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
  
  node_pools {
    node_quantity = var.nodes.luminaire.node_count
    plan          = var.nodes.luminaire.plan
    label         = var.nodes.luminaire.label
    auto_scaler   = var.nodes.luminaire.auto_scaler
    min_nodes     = var.nodes.luminaire.min_nodes
    max_nodes     = var.nodes.luminaire.max_nodes
    
    tag = "luminaire"
  }
  
  node_pools {
    node_quantity = var.nodes.thera.node_count
    plan          = var.nodes.thera.plan
    label         = var.nodes.thera.label
    auto_scaler   = var.nodes.thera.auto_scaler
    min_nodes     = var.nodes.thera.min_nodes
    max_nodes     = var.nodes.thera.max_nodes
    
    tag = "thera"
  }
  
  node_pools {
    node_quantity = var.nodes.jita.node_count
    plan          = var.nodes.jita.plan
    label         = var.nodes.jita.label
    auto_scaler   = var.nodes.jita.auto_scaler
    min_nodes     = var.nodes.jita.min_nodes
    max_nodes     = var.nodes.jita.max_nodes
    
    tag = "jita"
  }
  
  node_pools {
    node_quantity = var.nodes.umbra.node_count
    plan          = var.nodes.umbra.plan
    label         = var.nodes.umbra.label
    auto_scaler   = var.nodes.umbra.auto_scaler
    min_nodes     = var.nodes.umbra.min_nodes
    max_nodes     = var.nodes.umbra.max_nodes
    
    tag = "umbra"
  }
  
  node_pools {
    node_quantity = var.nodes.perimeter.node_count
    plan          = var.nodes.perimeter.plan
    label         = var.nodes.perimeter.label
    auto_scaler   = var.nodes.perimeter.auto_scaler
    min_nodes     = var.nodes.perimeter.min_nodes
    max_nodes     = var.nodes.perimeter.max_nodes
    
    tag = "perimeter"
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