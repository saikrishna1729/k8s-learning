# GKE Cluster Setup — Step by Step

## Prerequisites

1. Google Cloud account with billing enabled
2. gcloud CLI — `gcloud --version`
3. kubectl
4. helm (optional)

## Create GKE Standard Cluster

```bash
#!/bin/bash

PROJECT_ID="my-project"
CLUSTER_NAME="my-gke-cluster"
REGION="europe-west1"
ZONE="europe-west1-b"

# Set GCP project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com

# Create cluster
gcloud container clusters create $CLUSTER_NAME \
  --zone=$ZONE \
  --num-nodes=2 \
  --machine-type=n1-standard-1 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=5 \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-ip-alias \
  --network="default" \
  --enable-stackdriver-kubernetes

# Time: ~10-15 minutes
```

## Create GKE Autopilot Cluster

```bash
gcloud container clusters create-auto $CLUSTER_NAME \
  --location=$REGION \
  --project=$PROJECT_ID
```

Autopilot features:
- No node management (Google manages nodes)
- Auto-scaling built-in
- Security hardened by default
- Higher cost (~$0.10/hour base)

## Get Credentials

```bash
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID
```

## Verify Cluster

```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get all -A
```

## Scale Cluster

```bash
# Manual scaling
gcloud container clusters resize $CLUSTER_NAME \
  --num-nodes=3 \
  --zone=$ZONE

# Autoscaling is already enabled (min 1, max 5)
```

## Delete Cluster

```bash
gcloud container clusters delete $CLUSTER_NAME \
  --zone=$ZONE \
  --quiet
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

### Enable Workload Identity

```bash
# Already enabled in most cases; verify:
gcloud container clusters describe $CLUSTER_NAME \
  --zone=$ZONE \
  --format='value(workloadIdentityConfig.workloadPool)'
```

### Configure Network Policy

```bash
# Enable Dataplane V2 for Network Policies
gcloud container clusters update $CLUSTER_NAME \
  --zone=$ZONE \
  --enable-dataplane-v2
```

### Install Ingress Controller

```bash
# Google Cloud Load Balancer ingress (built-in)
# Just create an Ingress resource, GCP auto-creates LB

# Or install NGINX ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

## Enable Binary Authorization

```bash
gcloud container clusters update $CLUSTER_NAME \
  --zone=$ZONE \
  --enable-binary-authorization
```

## View Cluster Metrics

```bash
# In Google Cloud Console
# Goto: Kubernetes Engine > Clusters > [cluster name]

# Or via CLI
gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE
```

## Cost Monitoring

```bash
# View GKE pricing
gcloud container clusters describe $CLUSTER_NAME \
  --zone=$ZONE \
  --format='value(machineType,nodeCount)'

# Estimate costs
# GKE Standard: $0 control plane (included), ~$0.03/hour per n1-standard-1 node
# GKE Autopilot: ~$0.10/hour base + compute
```

## Troubleshooting

```bash
# View cluster events
kubectl get events -A --sort-by='.lastTimestamp'

# Check node status
kubectl get nodes -o wide
kubectl describe node <node-name>

# View GKE logs
gcloud logging read "resource.type=k8s_cluster" --limit 50 --format json
```

## References

- [GKE CLI Commands](https://cloud.google.com/sdk/gcloud/reference/container)
- [GKE Pricing](https://cloud.google.com/kubernetes-engine/pricing)
- [GKE Release Notes](https://cloud.google.com/kubernetes-engine/release-notes)
