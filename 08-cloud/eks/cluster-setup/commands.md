# EKS Cluster Setup — Step by Step

## Prerequisites

1. **AWS Account** — with IAM permissions for EC2, IAM, VPC, CloudFormation
2. **AWS CLI** — configure credentials
3. **kubectl** — v1.28+
4. **eksctl** — v0.150+ (optional but recommended)
5. **Terraform** — v1.0+ (if using Terraform)
6. **Helm** — v3.x (for add-ons)

## Option 1: Using eksctl (Fastest)

### 1. Create Cluster

```bash
eksctl create cluster --config-file=eksctl-cluster.yaml
```

This will:
- Create VPC with public/private subnets in 2 AZs
- Launch EKS control plane
- Create managed node group with 2 t3.medium nodes
- Install EBS CSI driver
- Configure OIDC provider for IRSA

**Time:** ~15-20 minutes

### 2. Verify Cluster

```bash
kubectl cluster-info
kubectl get nodes
kubectl get all -A
```

### 3. Cleanup

```bash
eksctl delete cluster --name my-cluster --region eu-west-1
```

---

## Option 2: Using Terraform

### 1. Initialize Terraform

```bash
cd terraform/
terraform init
```

### 2. Plan and Apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

**Time:** ~15-20 minutes

### 3. Configure kubectl

```bash
# Get the configure kubectl command from Terraform outputs
kubectl config use-context $(terraform output -raw configure_kubectl | grep -oP 'my-cluster')

# Or run directly
$(terraform output -raw configure_kubectl)
```

### 4. Verify

```bash
kubectl cluster-info
kubectl get nodes
```

### 5. Cleanup

```bash
terraform destroy
```

---

## Common Post-Setup Tasks

### Install AWS Load Balancer Controller

```bash
# Create IAM policy for ALB controller
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerPolicy \
  --policy-document file://iam_policy.json

# Install via Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster
```

### Install Cluster Autoscaler

```bash
eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::aws:policy/EKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve

helm install cluster-autoscaler eks/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=my-cluster
```

### Enable IRSA (IAM Roles for Service Accounts)

Already enabled if using eksctl or Terraform configs above. For manual setup:

```bash
# Verify OIDC provider exists
aws eks describe-cluster --name my-cluster --query 'cluster.identity.oidc.issuer' --output text

# Create OIDC provider in IAM (if not auto-created)
eksctl utils associate-iam-oidc-provider --cluster=my-cluster --approve
```

---

## Verify Setup

```bash
# Check nodes
kubectl get nodes -o wide

# Check add-ons
kubectl get all -n kube-system | grep -E '(coredns|vpc-cni|ebs-csi)'

# Check metrics
kubectl top nodes
kubectl top pods -A

# Check persistent volumes (for EBS)
kubectl get pv
kubectl get sc
```

---

## Cost Considerations

- **Control Plane:** ~$0.10/hour (always on)
- **Worker Nodes:** ~$0.03/hour per t3.medium on-demand
- **Data Transfer:** egress out of AWS = $0.02/GB
- **Load Balancers:** ~$16/month per ALB

**Total for this setup:** ~$70-100/month (2 nodes + control plane)

To reduce costs:
- Use spot instances for non-critical workloads
- Delete cluster when not in use
- Use Fargate for bursty workloads (pay per second)
- Monitor CloudWatch for underutilized nodes
