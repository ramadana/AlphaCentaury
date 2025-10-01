terraform {
  required_version = ">= 1.0"

  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    endpoint                    = "https://sgp1.vultrobjects.com"
    bucket                      = "skies-infra"
    key                         = "terraform/skies-nrt.tfstate"
    region                      = "sgp"

    # Vultr Object Storage compatibility options
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    force_path_style            = true

    # Access keys provided for the backend
    access_key = "Y9IRNULPFJGOZAOQO5O2"
    secret_key = "966ax8eKqk0legnJGX5mFytCnP6K6pl2iDqMke7s"
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

# Lookup existing VPC by its ID (Tokyo)
data "vultr_vpc" "nrt_skies" {
  filter {
    name   = "id"
    values = ["a4290707-a165-4517-a585-5112c992aa6b"]
  }
}

# VKE cluster (Tokyo) with initial node pool
# Note: VKE automatically creates a firewall group when enable_firewall = true
resource "vultr_kubernetes" "skies_nrt" {
  region          = "nrt"
  version         = var.kubernetes_version
  label           = "skies-nrt"
  enable_firewall = true
  vpc_id          = data.vultr_vpc.nrt_skies.id

  # Initial node pool: alikara (vhp-4c-8gb-amd)
  node_pools {
    node_quantity = 1
    plan          = "vhp-4c-8gb-amd"
    label         = "alikara"
    auto_scaler   = false
    min_nodes     = 1
    max_nodes     = 1
  }
}

# Additional node pool: sobaseki (vhp-2c-4gb-amd)
resource "vultr_kubernetes_node_pools" "sobaseki" {
  cluster_id    = vultr_kubernetes.skies_nrt.id
  node_quantity = 1
  plan          = "vhp-2c-4gb-amd"
  label         = "sobaseki"
  auto_scaler   = false
  min_nodes     = 1
  max_nodes     = 1
}

# Firewall rules for the VKE cluster
# These rules are added to the auto-generated firewall group
resource "vultr_firewall_rule" "allow_http" {
  firewall_group_id = vultr_kubernetes.skies_nrt.firewall_group_id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "80"
  notes             = "HTTP from anywhere"
}

resource "vultr_firewall_rule" "allow_https" {
  firewall_group_id = vultr_kubernetes.skies_nrt.firewall_group_id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "443"
  notes             = "HTTPS from anywhere"
}

resource "vultr_firewall_rule" "allow_range_bastion1" {
  firewall_group_id = vultr_kubernetes.skies_nrt.firewall_group_id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "45.32.103.199"
  subnet_size       = 32
  port              = "31501:31800"
  notes             = "App ports from 45.32.103.199/32"
}

resource "vultr_firewall_rule" "allow_range_bastion2" {
  firewall_group_id = vultr_kubernetes.skies_nrt.firewall_group_id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "149.28.159.131"
  subnet_size       = 32
  port              = "31501:31800"
  notes             = "App ports from 149.28.159.131/32"
}
