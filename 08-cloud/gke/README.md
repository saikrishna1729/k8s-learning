# ☁️ GKE — Google Kubernetes Engine

## Key Concepts

- **Managed Control Plane** — Google manages control plane. Cluster Masters (replicated across zones) are behind a load balancer.
- **Node Pools** — Groups of VMs (GCE instances) with shared config. Can have different machine types, autoscaling, and labels.
- **GKE Autopilot** — Fully managed Kubernetes (control plane + nodes). No node management. Good for hands-off deployments. Higher cost.
- **GKE Standard** — You manage nodes; Google manages control plane. Most control, most operational overhead.
- **Workload Identity** — GKE's equivalent of IRSA. Pods assume Google Service Accounts for GCP API access.
- **Google Cloud Logging & Monitoring** — Built-in integration with Cloud Logging and Cloud Monitoring.

## Key Learnings

- **GKE is arguably the most mature K8s service** — Google created Kubernetes and runs thousands of clusters.
- **Autopilot is expensive but convenient** — good for small projects or proof-of-concepts. Standard is cheaper for production.
- **Workload Identity is simpler than IRSA** — just annotate ServiceAccount with Google SA email.
- **Network Policy requires Dataplane V2** — not enabled by default; enable it if you need Pod-to-Pod firewall rules.
- **Preemptible instances save 70%** — but can be evicted with 30-second notice. Good for non-critical workloads.

## Quick Start

### Prerequisites

- Google Cloud account with billing enabled
- gcloud CLI installed and authenticated
- kubectl
- helm

### Create Cluster (gcloud CLI)

```bash
# Set variables
PROJECT_ID="my-project"
CLUSTER_NAME="my-gke-cluster"
REGION="europe-west1"
ZONE="europe-west1-b"

# Set project
gcloud config set project $PROJECT_ID

# Create GKE Standard cluster
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

# Get credentials
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

# Verify
kubectl cluster-info
kubectl get nodes
```

See `cluster-setup/` for Terraform example and Autopilot commands.

## References

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
