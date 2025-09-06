# Skies Infrastructure - Multi-Region Kubernetes on Vultr

This Terraform project provisions a complete multi-region Kubernetes infrastructure on Vultr with Cloudflare load balancing.

## Architecture Overview

### Regions
- **Singapore (SGP)**: Primary cluster with bastion and CI/CD hosts
- **Tokyo (NRT)**: Failover cluster

### Node Layout (Per Cluster)
- **Luminaire**: Monitoring stack (Grafana, Prometheus, Loki, Metabase)
- **Thera**: Database workloads
- **Jita**: Backend services and Kafka
- **Umbra**: Frontend applications  
- **Perimeter**: API Gateway (Apache APISIX)

### Additional Infrastructure
- **Stargate** (SGP only): Bastion host for secure access
- **Ethernity** (SGP only): GitHub self-hosted runners
- **Cloudflare Load Balancer**: Global traffic distribution with health checks
- **Vultr Container Registry**: `sgp.vultrcr.com/skies`

## Quick Start

### 1. Prerequisites
- Vultr API key
- Cloudflare API token 
- Domain configured in Cloudflare
- SSH key pair

### 2. Setup
```bash
git clone <this-repo>
cd skies-infrastructure
chmod +x setup.sh
./setup.sh
```

### 3. Configure
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Deploy
```bash
terraform plan
terraform apply
```

### 5. Connect to Clusters
```bash
./extract-kubeconfig.sh
./connect-cluster.sh sgp  # Singapore
./connect-cluster.sh nrt  # Tokyo
```

## Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output values
├── terraform.tfvars.example
├── modules/
│   ├── region/            # VKE cluster and VPS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── templates/
│   │       └── cloud-init.yml
│   └── cloudflare/        # Load balancer module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── setup.sh              # Automated setup script
├── extract-kubeconfig.sh # Extract cluster configs
├── connect-cluster.sh    # Connect to specific cluster
├── status.sh            # Check deployment status
├── DEPLOYMENT_GUIDE.md  # Detailed deployment guide
└── README.md           # This file
```

## Resource Specifications

### Default Node Sizes
- **Luminaire**: 2 vCPU, 4GB RAM (monitoring)
- **Thera**: 4 vCPU, 8GB RAM (databases) 
- **Jita**: 4 vCPU, 8GB RAM (backends + Kafka)
- **Umbra**: 2 vCPU, 4GB RAM (frontends)
- **Perimeter**: 2 vCPU, 4GB RAM (API gateway)

### VPS Instances
- **Stargate**: 1 vCPU, 2GB RAM (bastion)
- **Ethernity**: 4 vCPU, 8GB RAM (GitHub runners)

All instances use **Flatcar Container Linux** as the operating system.

## Helper Scripts

- **setup.sh**: Automated environment setup
- **extract-kubeconfig.sh**: Extract cluster configs after deployment  
- **connect-cluster.sh**: Switch between clusters
- **status.sh**: Check infrastructure status

## Key Features

- ✅ Multi-region deployment (Singapore + Tokyo)
- ✅ Automated failover with Cloudflare Load Balancer
- ✅ Dedicated node pools for workload isolation
- ✅ Bastion host for secure access
- ✅ Self-hosted GitHub runners
- ✅ Container registry integration
- ✅ Infrastructure as Code with Terraform
- ✅ Comprehensive monitoring setup ready

## Cost Estimation

Based on default configurations:
- **Singapore**: ~$200-250/month (5 nodes + 2 VPS)
- **Tokyo**: ~$150-200/month (5 nodes)
- **Total**: ~$350-450/month

*Prices may vary based on Vultr pricing and actual usage*

## Security

- SSH key-based authentication only
- Firewall rules for essential ports
- Private networking where possible
- Bastion host for secure cluster access

## Monitoring & Observability

The **Luminaire** nodes are pre-configured to host:
- **Grafana**: Dashboards and visualization
- **Prometheus**: Metrics collection
- **Loki**: Log aggregation  
- **Metabase**: Business intelligence

## Support

For detailed deployment instructions, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Made for the Skies project** 🚀