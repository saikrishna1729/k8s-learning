# ☁️ AKS — Azure Kubernetes Service

## Key Concepts

- **Managed Control Plane** — Azure manages control plane (API server, etcd, scheduler). You manage node pools via VMSS (Virtual Machine Scale Sets).
- **Node Pools** — Managed groups of VMs with shared config (size, scale, OS). Can have different VM types and autoscaling.
- **Azure AD Integration** — Native Azure AD authentication for Kubernetes RBAC (no separate identity system needed).
- **Azure CNI** — Kubernetes networking uses Azure VNet IPs directly. Pods get IPs from VNet subnets.
- **Managed Identity** — Azure-native way to grant permissions; similar to AWS IRSA but simpler.
- **Azure Container Registry** — Integrated container registry with AKS.

## Key Learnings

- **AKS is simpler for Azure-native shops** — tight integration with Azure AD, VNets, Storage, etc.
- **Node pool autoscaling is per-pool** — each pool scales independently based on demand.
- **Azure AD RBAC is easier than Kubernetes RBAC** — if using Azure AD, use it for auth; Kubernetes RBAC for fine-grained permissions.
- **Azure disks are region-specific** — can't easily move between regions; design for failure within region.
- **Cost model is similar to EKS** — pay for control plane (~$0.10/hour) + nodes.

## Quick Start

### Prerequisites

- Azure account with subscription
- Azure CLI installed and authenticated
- kubectl
- helm

### Create Cluster (Azure CLI)

```bash
# Set variables
RESOURCE_GROUP="my-resource-group"
CLUSTER_NAME="my-aks-cluster"
REGION="westeurope"

# Create resource group
az group create --name $RESOURCE_GROUP --location $REGION

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-managed-identity \
  --enable-cluster-autoscaling \
  --min-count 1 \
  --max-count 5 \
  --network-plugin azure \
  --docker-bridge-address 172.17.0.1/16 \
  --service-cidr 10.0.0.0/16 \
  --dns-service-ip 10.0.0.10 \
  --generate-ssh-keys

# Get kubeconfig
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Verify
kubectl cluster-info
kubectl get nodes
```

See `cluster-setup/` for Terraform example.

## References

- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
