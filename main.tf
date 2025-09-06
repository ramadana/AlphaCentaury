# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    # Configure your remote state backend here
    # bucket = "your-terraform-state-bucket"
    # key    = "skies/terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Data sources
data "vultr_region" "sgp" {
  filter {
    name   = "id"
    values = ["sgp"]
  }
}

data "vultr_region" "nrt" {
  filter {
    name   = "id"
    values = ["nrt"]
  }
}

data "vultr_os" "flatcar" {
  filter {
    name   = "name"
    values = ["Flatcar Container Linux"]
  }
}

# Singapore Infrastructure
module "singapore" {
  source = "./modules/region"
  
  region_code    = "sgp"
  cluster_name   = "skies-sgp"
  region_id      = data.vultr_region.sgp.id
  os_id          = data.vultr_os.flatcar.id
  
  # VKE Configuration
  vke_version = var.kubernetes_version
  
  # Node configurations
  nodes = {
    luminaire = {
      plan        = var.node_plans.luminaire
      label       = "luminaire"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    thera = {
      plan        = var.node_plans.thera
      label       = "thera"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    jita = {
      plan        = var.node_plans.jita
      label       = "jita"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    umbra = {
      plan        = var.node_plans.umbra
      label       = "umbra"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    perimeter = {
      plan        = var.node_plans.perimeter
      label       = "perimeter"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
  }
  
  # VPS instances
  vps_instances = {
    stargate = {
      plan    = var.vps_plans.stargate
      label   = "stargate-sgp"
      hostname = "stargate.sgp.skies.local"
    }
    ethernity = {
      plan     = var.vps_plans.ethernity
      label    = "ethernity-sgp"
      hostname = "ethernity.sgp.skies.local"
    }
  }
  
  # SSH Key
  ssh_key_ids = [vultr_ssh_key.main.id]
  
  tags = {
    Environment = var.environment
    Project     = "skies"
    Region      = "singapore"
  }
}

# Tokyo Infrastructure  
module "tokyo" {
  source = "./modules/region"
  
  region_code    = "nrt"
  cluster_name   = "skies-nrt"
  region_id      = data.vultr_region.nrt.id
  os_id          = data.vultr_os.flatcar.id
  
  # VKE Configuration
  vke_version = var.kubernetes_version
  
  # Node configurations (identical to Singapore)
  nodes = {
    luminaire = {
      plan        = var.node_plans.luminaire
      label       = "luminaire"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    thera = {
      plan        = var.node_plans.thera
      label       = "thera"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    jita = {
      plan        = var.node_plans.jita
      label       = "jita"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    umbra = {
      plan        = var.node_plans.umbra
      label       = "umbra"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
    perimeter = {
      plan        = var.node_plans.perimeter
      label       = "perimeter"
      auto_scaler = false
      min_nodes   = 1
      max_nodes   = 1
      node_count  = 1
    }
  }
  
  # No VPS instances in Tokyo (failover cluster only)
  vps_instances = {}
  
  # SSH Key
  ssh_key_ids = [vultr_ssh_key.main.id]
  
  tags = {
    Environment = var.environment
    Project     = "skies"
    Region      = "tokyo"
  }
}

# SSH Key
resource "vultr_ssh_key" "main" {
  name    = "skies-main-key"
  ssh_key = var.ssh_public_key
}

# Cloudflare Load Balancer
module "cloudflare_lb" {
  source = "./modules/cloudflare"
  
  zone_id = var.cloudflare_zone_id
  
  # Origins from both regions
  origins = {
    singapore = {
      name    = "skies-sgp"
      address = module.singapore.cluster_endpoint
      enabled = true
      weight  = 1.0
    }
    tokyo = {
      name    = "skies-nrt" 
      address = module.tokyo.cluster_endpoint
      enabled = true
      weight  = 0.5  # Lower weight for failover
    }
  }
  
  # Health check configuration
  health_check = {
    enabled     = true
    path        = "/health"
    interval    = 60
    retries     = 2
    timeout     = 5
    method      = "GET"
    expected_codes = "200"
  }
  
  # Pool configuration
  pool_name        = "skies-main-pool"
  load_balancer_name = var.domain_name
  
  tags = {
    Environment = var.environment
    Project     = "skies"
  }
}