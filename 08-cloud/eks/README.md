# ☁️ EKS — AWS Elastic Kubernetes Service

## Key Concepts

- **Managed Control Plane** — AWS manages Kubernetes API server, etcd, scheduler. You manage worker nodes via EC2 Auto Scaling Groups or Fargate.
- **Node Groups** — Managed groups of EC2 instances (on-demand or spot). Can have different instance types, taints, labels, and availability zones.
- **Fargate** — Serverless compute; AWS provisions pods directly without managing EC2 nodes. Higher price, no cluster autoscaling.
- **IAM Roles for Service Accounts (IRSA)** — Pods can assume IAM roles to access AWS services (S3, DynamoDB, etc.) with temporary credentials.
- **EKS Add-ons** — Managed add-ons: VPC CNI, CoreDNS, kube-proxy, EBS CSI driver. Auto-updated alongside cluster version.
- **VPC CNI (Container Network Interface)** — AWS networking plugin. Pods get IPs from VPC subnets directly (not overlay). Limits pods/node based on ENI count.

## Key Learnings

- **EKS control plane is highly available** — multi-AZ by default, managed by AWS. You don't manage it, but pay for it (~$0.10/hour).
- **Always use node groups, not self-managed ASGs** — node groups auto-configure security groups, IAM roles, kubelet, etc. Self-managed is error-prone.
- **Fargate has cold-start latency** — ~30-60 seconds to provision a Pod. Not suitable for performance-sensitive workloads. Good for batch jobs.
- **VPC CNI limits pod density** — each ENI attachment limits IPs; fewer ENIs = fewer pods per node. Use prefix delegation mode if scaling pods/node.
- **ALB Ingress vs NLB** — ALB (Application Load Balancer) for HTTP/HTTPS, best for web apps. NLB for TCP/UDP, extreme throughput. Configure via AWS Load Balancer Controller.
- **IRSA requires OIDC provider** — eksctl handles it; manual setup requires creating OIDC provider in IAM, then annotating ServiceAccount.
- **Regional control** — choose region carefully for latency and cost. eu-west-1 (Ireland) is cheaper than us-east-1.

## Prerequisites

- AWS account with IAM permissions (EC2, IAM, VPC, CloudFormation)
- `aws` CLI configured with credentials
- `kubectl` (v1.28+)
- `helm` (v3.x)
- `eksctl` (v0.150+) — optional but highly recommended

## CLI Quick Start

```bash
# Configure AWS credentials
aws configure

# Create a basic EKS cluster with eksctl (fastest)
eksctl create cluster --name my-cluster --region eu-west-1 --nodegroup-name nodes --nodes 2 --node-type t3.medium

# Get kubeconfig
aws eks update-kubeconfig --region eu-west-1 --name my-cluster

# Verify
kubectl cluster-info
kubectl get nodes
```

See `cluster-setup/` for detailed setup guides and Terraform examples.
