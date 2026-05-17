# AKS Cluster Setup — Step by Step

## Prerequisites

1. Azure account with subscription
2. Azure CLI — `az --version`
3. kubectl
4. helm (optional)

## Create Cluster via Azure CLI

```bash
#!/bin/bash

RESOURCE_GROUP="my-resource-group"
CLUSTER_NAME="my-aks-cluster"
REGION="westeurope"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $REGION

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

# Time: ~10-15 minutes
```

## Get Credentials

```bash
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME
```

## Verify Cluster

```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get all -A
```

## Scale Nodes

```bash
# Manual scaling
az aks scale \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3

# Cluster autoscaling is already enabled (min 1, max 5)
```

## Delete Cluster

```bash
az aks delete \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --yes --no-wait

# Clean up resource group
az group delete \
  --name $RESOURCE_GROUP \
  --yes --no-wait
```

## Using Terraform

See `terraform/main.tf` for infrastructure-as-code example.

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

## Common Post-Setup Tasks

### Enable RBAC

RBAC is enabled by default in AKS. Azure AD integration is optional:

```bash
# Enable Azure AD integration
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-aad \
  --aad-admin-group-object-ids <objectid>
```

### Scale Node Pool

```bash
# List node pools
az aks nodepool list \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME

# Scale specific pool
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name nodepool1 \
  --node-count 3
```

### Install Ingress Controller

```bash
# NGINX ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

## Cost Monitoring

```bash
# Get cluster cost estimate
az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --query '{SKU: sku.name, Region: location}'

# View actual costs in Azure Portal
# Goto Cost Management + Billing
```

## Troubleshooting

```bash
# View cluster diagnostics
az aks diagnostics get-diagnostics-support-packages \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME

# Check node status
kubectl get nodes -o wide

# View events
kubectl get events -A --sort-by='.lastTimestamp'
```

## References

- [AKS CLI Commands](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest)
- [AKS Pricing](https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/)
