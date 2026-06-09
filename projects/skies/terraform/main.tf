terraform {
  required_version = ">= 1.0"

  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.31.2"
    }
  }

  backend "s3" {
    endpoint = "https://sgp1.vultrobjects.com"
    bucket   = "skies-infra"
    key      = "terraform/skies-noc.tfstate"
    region   = "sgp"

    # Vultr Object Storage S3 compatibility
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    force_path_style            = true

    # Provide credentials via environment variables before running terraform:
    #   export AWS_ACCESS_KEY_ID="<vultr-object-storage-access-key>"
    #   export AWS_SECRET_ACCESS_KEY="<vultr-object-storage-secret-key>"
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

locals {
  cluster_label = "skies-noc"

  # First pool must be declared inline on vultr_kubernetes; the rest are separate resources.
  initial_node_pool = "arnon"
  additional_node_pools = {
    for name, pool in var.node_pools : name => pool if name != local.initial_node_pool
  }

  vpc_id = var.create_vpc ? vultr_vpc.skies_noc[0].id : var.vpc_id

  # VKE firewall is deny-by-default; only these inbound TCP ports are permitted.
  firewall_rules = {
    http = {
      port  = "80"
      notes = "HTTP"
    }
    https = {
      port  = "443"
      notes = "HTTPS"
    }
    tcp_30422 = {
      port  = "30422"
      notes = "Custom SSH port to access bastion host"
      cidr_blocks = ["10.40.112.3/32"]
    }
    tcp_31101 = {
      port  = "31101"
      notes = "Custom NodePort to manage PostgreSQL database"
      cidr_blocks = ["10.40.112.3/32"]
    }
  }
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

resource "vultr_vpc" "skies_noc" {
  count = var.create_vpc ? 1 : 0

  region         = var.region
  description    = var.vpc_description
  v4_subnet      = var.vpc_v4_subnet
  v4_subnet_mask = var.vpc_v4_subnet_mask
}

# ------------------------------------------------------------------------------
# VKE cluster — skies-noc (Singapore)
#
# Node layout (clusters-schema.txt):
#   arnon  (2c/4gb) — Nginx/APISIX ingress, Loki, Bastion
#   yulai  (2c/4gb) — Metabase, Grafana, PostgreSQL
#   thera  (2c/4gb) — Prometheus, GitHub Actions runners
# ------------------------------------------------------------------------------

resource "vultr_kubernetes" "skies_noc" {
  region          = var.region
  version         = var.kubernetes_version
  label           = local.cluster_label
  enable_firewall = true
  vpc_id          = local.vpc_id

  node_pools {
    node_quantity = var.node_pools[local.initial_node_pool].quantity
    plan          = var.node_pools[local.initial_node_pool].plan
    label         = local.initial_node_pool
    auto_scaler   = false
    min_nodes     = var.node_pools[local.initial_node_pool].quantity
    max_nodes     = var.node_pools[local.initial_node_pool].quantity
  }
}

resource "vultr_kubernetes_node_pools" "additional" {
  for_each = local.additional_node_pools

  cluster_id    = vultr_kubernetes.skies_noc.id
  node_quantity = each.value.quantity
  plan          = each.value.plan
  label         = each.key
  auto_scaler   = false
  min_nodes     = each.value.quantity
  max_nodes     = each.value.quantity
}

# ------------------------------------------------------------------------------
# Firewall — deny all except explicit inbound TCP allows below
# ------------------------------------------------------------------------------

resource "vultr_firewall_rule" "ingress" {
  for_each = local.firewall_rules

  firewall_group_id = vultr_kubernetes.skies_noc.firewall_group_id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = each.value.port
  notes             = each.value.notes
}
