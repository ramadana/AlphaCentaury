# SKIES NOC — Terraform (Vultr VKE)

Provisions the **skies-noc** Kubernetes cluster in Singapore: observability, utility, and bastion workloads.

See [clusters-schema.txt](../clusters-schema.txt) for the full multi-cluster plan. This module covers **skies-noc only**.

## Cluster Layout

| Node Pool | Plan | Workloads |
|-----------|------|-----------|
| **arnon** | 2 vCPU / 4 GB | Nginx / APISIX ingress, Loki, Bastion |
| **yulai** | 2 vCPU / 4 GB | Metabase, Grafana, PostgreSQL |
| **thera** | 2 vCPU / 4 GB | Prometheus, GitHub Actions runners |

**Estimated cost:** ~$72/month (3 × `vhp-2c-4gb-amd` nodes)

## Prerequisites

- Vultr API key
- Vultr Object Storage credentials (for remote Terraform state)
- `terraform` >= 1.0

## Setup

```bash
cd Projects/SKIES/terraform

# 1. Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

# 2. Set Object Storage credentials for remote state
export AWS_ACCESS_KEY_ID="<vultr-object-storage-access-key>"
export AWS_SECRET_ACCESS_KEY="<vultr-object-storage-secret-key>"

# 3. Review before applying
terraform init
terraform plan
```

## Apply (when ready)

```bash
terraform apply
```

After apply, extract kubeconfig:

```bash
terraform output -raw kube_config > ../k8s/vke-skies-noc.yml
```

## State

Remote state is stored at:

```
s3://skies-infra/terraform/skies-noc.tfstate
```

This replaces the previous `skies-nrt.tfstate` key. If you have existing NRT state, it is left untouched in Object Storage but no longer referenced by this configuration.

## VPC Options

| Mode | Setting |
|------|---------|
| Create new VPC | `create_vpc = true` (default) |
| Use existing VPC | `create_vpc = false` + `vpc_id = "..."` |

Default new VPC subnet: `10.41.0.0/16` — adjust `vpc_v4_subnet` if it overlaps with existing SKIES VPCs (e.g. `10.40.112.0/24` used elsewhere).

## Existing Cluster Warning

A skies-noc VKE cluster may already exist (see `k8s/vke-skies-noc.yml`). Running `terraform apply` on a **new** state file will attempt to **create a second cluster**.

Before applying, choose one path:

1. **Fresh cluster** — destroy the old cluster manually in Vultr, then apply
2. **Import existing** — import the existing cluster and node pools into this state (contact before doing this)

## Firewall

VKE firewall is **deny-by-default**. Only these inbound TCP ports are allowed (from anywhere):

| Port | Protocol |
|------|----------|
| 80 | HTTP |
| 443 | HTTPS |
| 30422 | TCP |
| 31101 | TCP |

All other inbound connections are dropped. Rules are defined in `main.tf` under `local.firewall_rules`.

## Files

```
terraform/
├── main.tf                  # Cluster, node pools, firewall
├── variables.tf             # Input variables
├── outputs.tf               # Cluster outputs
├── terraform.tfvars.example # Template (copy to terraform.tfvars)
└── README.md                # This file
```
