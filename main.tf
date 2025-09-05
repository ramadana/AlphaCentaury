resource "vultr_ssh_key" "main" {
  name = "skies-key"
  key  = var.ssh_public_key
}

# Create each cluster via module
module "clusters" {
  source = "./modules/cluster"

  for_each = var.clusters

  cluster_name   = each.key
  region         = each.value.region
  vpc_cidr       = each.value.vpc_cidr
  label          = each.value.label
  control_plane  = each.value.control_plane
  nodes          = each.value.nodes
  ssh_key_id     = vultr_ssh_key.main.id
}