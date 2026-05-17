# Cluster Autoscaler

Cluster Autoscaler automatically adjusts the number of nodes in your cluster based on Pod scheduling constraints and node utilization.

## How It Works

1. **Scale Out:** When a Pod cannot be scheduled on any existing node (pending state), Cluster Autoscaler adds a new node.
2. **Scale In:** When a node has low utilization for an extended period, Cluster Autoscaler removes it (after draining Pods).

## EKS Setup

Cluster Autoscaler requires IAM permissions to create/destroy EC2 instances and read ASG data.

### Option 1: IRSA (Recommended)

```bash
# Create IAM policy
cat > /tmp/cluster-autoscaler-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy --policy-name EKSClusterAutoscalerPolicy \
  --policy-document file:///tmp/cluster-autoscaler-policy.json

# Create service account and IAM role
eksctl create iamserviceaccount \
  --cluster=<cluster-name> \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::<account-id>:policy/EKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve
```

### Option 2: Helm Install

```bash
helm repo add autoscaling https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaling/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=<cluster-name> \
  --set awsRegion=<region> \
  --set rbac.serviceAccount.create=false \
  --set rbac.serviceAccount.name=cluster-autoscaler
```

## Configuration

```bash
# View Cluster Autoscaler logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler -f

# Check scaling activities
kubectl describe nodes | grep -i "unschedulable"
```

## Modern Alternative: Karpenter

Karpenter is a newer replacement for Cluster Autoscaler with:
- Faster provisioning (seconds vs minutes)
- Consolidation (bin-packing nodes, cost optimization)
- Flexible node templates (no need to pre-define ASGs)
- Custom metrics support

Learn more: https://karpenter.sh/

## Cost Considerations

- Each new node incurs hourly charges (even 1 CPU counts as 1 hour)
- Scale-in can take 10-20 minutes (safety window to prevent flapping)
- Set appropriate min/max node counts to avoid bill shock
- Consider spot instances for non-critical workloads
