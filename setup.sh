#!/bin/bash
# setup.sh - Skies Infrastructure Setup Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_VERSION="1.13.1"
KUBECTL_VERSION="v1.32.2"
PROJECT_NAME="skies-infrastructure"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE} Skies Infrastructure Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Terraform
install_terraform() {
    echo -e "${YELLOW}Installing Terraform...${NC}"
    
    if command_exists terraform; then
        CURRENT_VERSION=$(terraform version -json | jq -r '.terraform_version')
        echo "Terraform $CURRENT_VERSION is already installed"
        return 0
    fi
    
    # Download and install Terraform
    case "$(uname -s)" in
        Linux*)
            PLATFORM="linux_amd64"
            ;;
        Darwin*)
            PLATFORM="darwin_amd64"
            ;;
        *)
            echo -e "${RED}Unsupported platform$(NC)"
            exit 1
            ;;
    esac
    
    wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip"
    unzip "terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip"
    sudo mv terraform /usr/local/bin/
    rm "terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip"
    
    echo -e "${GREEN}Terraform installed successfully!${NC}"
}

# Function to install kubectl
install_kubectl() {
    echo -e "${YELLOW}Installing kubectl...${NC}"
    
    if command_exists kubectl; then
        echo "kubectl is already installed"
        return 0
    fi
    
    # Download and install kubectl
    case "$(uname -s)" in
        Linux*)
            curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
            ;;
        Darwin*)
            curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/darwin/amd64/kubectl"
            ;;
        *)
            echo -e "${RED}Unsupported platform${NC}"
            exit 1
            ;;
    esac
    
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    echo -e "${GREEN}kubectl installed successfully!${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check for required tools
    local missing_tools=()
    
    if ! command_exists curl; then
        missing_tools+=("curl")
    fi
    
    if ! command_exists wget; then
        missing_tools+=("wget")
    fi
    
    if ! command_exists jq; then
        missing_tools+=("jq")
    fi
    
    if ! command_exists unzip; then
        missing_tools+=("unzip")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}Missing required tools: ${missing_tools[*]}${NC}"
        echo "Please install them using your package manager:"
        echo "  Ubuntu/Debian: sudo apt-get install ${missing_tools[*]}"
        echo "  CentOS/RHEL: sudo yum install ${missing_tools[*]}"
        echo "  macOS: brew install ${missing_tools[*]}"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed!${NC}"
}

# Function to setup Terraform configuration
setup_terraform() {
    echo -e "${YELLOW}Setting up Terraform configuration...${NC}"
    
    # Initialize Terraform
    terraform init
    
    # Validate configuration
    terraform validate
    
    if [ ! -f "terraform.tfvars" ]; then
        echo -e "${YELLOW}Creating terraform.tfvars from example...${NC}"
        cp terraform.tfvars.example terraform.tfvars
        echo -e "${RED}Please edit terraform.tfvars with your actual values before running terraform plan/apply!${NC}"
    fi
    
    echo -e "${GREEN}Terraform setup completed!${NC}"
}

# Function to create kubeconfig directory
setup_kubeconfig() {
    echo -e "${YELLOW}Setting up kubeconfig directory...${NC}"
    
    mkdir -p ~/.kube/skies
    chmod 700 ~/.kube
    chmod 700 ~/.kube/skies
    
    echo -e "${GREEN}Kubeconfig directory created!${NC}"
}

# Function to create helper scripts
create_helper_scripts() {
    echo -e "${YELLOW}Creating helper scripts...${NC}"
    
    # Create kubeconfig extraction script
    cat > extract-kubeconfig.sh << 'EOF'
#!/bin/bash
# extract-kubeconfig.sh - Extract kubeconfig from Terraform output

set -e

echo "Extracting kubeconfig files..."

# Extract Singapore kubeconfig
terraform output -raw singapore_kubeconfig | base64 -d > ~/.kube/skies/sgp-kubeconfig
chmod 600 ~/.kube/skies/sgp-kubeconfig

# Extract Tokyo kubeconfig
terraform output -raw tokyo_kubeconfig | base64 -d > ~/.kube/skies/nrt-kubeconfig
chmod 600 ~/.kube/skies/nrt-kubeconfig

echo "Kubeconfig files extracted to ~/.kube/skies/"
echo ""
echo "To use:"
echo "  Singapore cluster: export KUBECONFIG=~/.kube/skies/sgp-kubeconfig"
echo "  Tokyo cluster:     export KUBECONFIG=~/.kube/skies/nrt-kubeconfig"
echo ""
echo "Or merge them into your main config:"
echo "  KUBECONFIG=~/.kube/config:~/.kube/skies/sgp-kubeconfig:~/.kube/skies/nrt-kubeconfig kubectl config view --merge --flatten > ~/.kube/merged_config"
echo "  mv ~/.kube/merged_config ~/.kube/config"
EOF
    
    chmod +x extract-kubeconfig.sh
    
    # Create cluster connection script
    cat > connect-cluster.sh << 'EOF'
#!/bin/bash
# connect-cluster.sh - Connect to specific cluster

CLUSTER=${1:-sgp}

case $CLUSTER in
    sgp|singapore)
        export KUBECONFIG=~/.kube/skies/sgp-kubeconfig
        echo "Connected to Singapore cluster"
        ;;
    nrt|tokyo)
        export KUBECONFIG=~/.kube/skies/nrt-kubeconfig
        echo "Connected to Tokyo cluster"
        ;;
    *)
        echo "Usage: $0 [sgp|nrt]"
        exit 1
        ;;
esac

kubectl cluster-info
EOF
    
    chmod +x connect-cluster.sh
    
    # Create deployment status script
    cat > status.sh << 'EOF'
#!/bin/bash
# status.sh - Check infrastructure status

echo "=== Infrastructure Status ==="
echo ""

# Check Terraform status
echo "Terraform State:"
terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[] | select(.type == "vultr_kubernetes") | "\(.values.label): \(.values.status)"' || echo "Run terraform apply first"

echo ""
echo "Resource Summary:"
terraform output infrastructure_summary 2>/dev/null || echo "No outputs available"

echo ""
echo "VPS Instances:"
terraform output singapore_vps_instances 2>/dev/null || echo "No VPS instances deployed"
EOF
    
    chmod +x status.sh
    
    echo -e "${GREEN}Helper scripts created!${NC}"
    echo "  - extract-kubeconfig.sh: Extract kubeconfig files after deployment"
    echo "  - connect-cluster.sh: Connect to specific cluster (sgp/nrt)"
    echo "  - status.sh: Check infrastructure deployment status"
}

# Function to create deployment guide
create_deployment_guide() {
    echo -e "${YELLOW}Creating deployment guide...${NC}"
    
    cat > DEPLOYMENT_GUIDE.md << 'EOF'
# Skies Infrastructure Deployment Guide

## Prerequisites
- Vultr API key with compute permissions
- Cloudflare API token with zone and load balancer permissions
- SSH key pair for instance access
- Domain configured in Cloudflare

## Deployment Steps

### 1. Initial Setup
```bash
./setup.sh
```

### 2. Configure Variables
Edit `terraform.tfvars` with your actual values:
- API keys and tokens
- Domain name and Cloudflare zone ID
- SSH public key
- Adjust instance sizes if needed

### 3. Deploy Infrastructure
```bash
# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

### 4. Extract Kubeconfig
```bash
./extract-kubeconfig.sh
```

### 5. Connect to Clusters
```bash
# Connect to Singapore cluster
./connect-cluster.sh sgp

# Connect to Tokyo cluster  
./connect-cluster.sh nrt
```

### 6. Verify Deployment
```bash
# Check overall status
./status.sh

# Test cluster connectivity
kubectl get nodes
```

## Node Labels and Taints

Each node pool has specific labels for workload placement:

- **luminaire**: Monitoring stack (Grafana, Prometheus, Loki, Metabase)
- **thera**: Database workloads
- **jita**: Backend services and Kafka
- **umbra**: Frontend applications
- **perimeter**: API Gateway (Apache APISIX)

Use nodeSelectors in your Kubernetes manifests:
```yaml
spec:
  nodeSelector:
    vultr.com/node-pool: luminaire
```

## Container Registry

Your Vultr container registry is configured at:
- Registry URL: `sgp.vultrcr.com/skies`
- Use this in your Kubernetes manifests and CI/CD pipelines

## VPS Instances

### Stargate (Bastion Host)
- Access: SSH to the IP from terraform output
- Purpose: Secure access to clusters and management
- Kubeconfig files will be available after running extract-kubeconfig.sh

### Ethernity (GitHub Runners)
- Access: SSH to the IP from terraform output  
- Purpose: Self-hosted GitHub Actions runners
- Complete setup: Follow instructions in the cloud-init output

## Load Balancing

Cloudflare Load Balancer is configured with:
- Primary: Singapore cluster (weight 1.0)
- Failover: Tokyo cluster (weight 0.5)
- Health checks on /health endpoint

## Security Considerations

1. **SSH Access**: Only key-based authentication enabled
2. **Firewall**: Basic rules applied to VPS instances
3. **Network**: Clusters use private networking where possible
4. **API Keys**: Store securely, use environment variables in CI/CD

## Scaling

To scale nodes:
1. Update node_count in terraform.tfvars
2. Run `terraform plan` and `terraform apply`

To add new node pools:
1. Add to the nodes configuration in variables
2. Update the region module accordingly

## Troubleshooting

### Common Issues
1. **API Rate Limits**: Wait and retry terraform commands
2. **Resource Limits**: Check Vultr account limits
3. **DNS Propagation**: Cloudflare changes may take time to propagate

### Logs and Monitoring
- Check cloud-init logs: `sudo journalctl -u cloud-final`
- Kubernetes logs: `kubectl logs -n kube-system`
- VPS access: Use Stargate bastion host

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete all infrastructure. Make sure you have backups of any important data.
EOF
    
    echo -e "${GREEN}Deployment guide created: DEPLOYMENT_GUIDE.md${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting setup for $PROJECT_NAME...${NC}"
    echo ""
    
    check_prerequisites
    install_terraform
    install_kubectl
    setup_terraform
    setup_kubeconfig
    create_helper_scripts
    create_deployment_guide
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN} Setup completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Edit terraform.tfvars with your actual values"
    echo "2. Run: terraform plan"
    echo "3. Run: terraform apply"
    echo "4. Run: ./extract-kubeconfig.sh"
    echo ""
    echo -e "${BLUE}Read DEPLOYMENT_GUIDE.md for detailed instructions${NC}"
}

# Run main function
main "$@"