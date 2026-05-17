# AWS Load Balancer Controller

The AWS Load Balancer Controller manages AWS Elastic Load Balancers (ALB/NLB) based on Kubernetes Ingress and Service resources. It replaces the legacy "in-tree" AWS cloud controller.

## Prerequisites

- EKS cluster with IRSA enabled
- kubectl access
- Helm

## Install

### Step 1: Create IAM Policy

```bash
curl -o /tmp/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file:///tmp/iam_policy.json
```

### Step 2: Create ServiceAccount with IRSA

```bash
CLUSTER_NAME="my-cluster"
REGION="eu-west-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

eksctl create iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

### Step 3: Install via Helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Step 4: Verify

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller -f
```

## Create ALB Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: default
  annotations:
    alb.ingress.kubernetes.io/load-balancer-name: my-alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
spec:
  ingressClassName: alb
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

## Common Annotations

| Annotation | Value | Description |
|-----------|-------|-------------|
| `alb.ingress.kubernetes.io/scheme` | `internet-facing` or `internal` | Public or private ALB |
| `alb.ingress.kubernetes.io/target-type` | `ip` or `instance` | Pod IPs or EC2 node IPs |
| `alb.ingress.kubernetes.io/listen-ports` | `'[{"HTTP": 80}]'` | Listener ports and protocols |
| `alb.ingress.kubernetes.io/ssl-redirect` | `'443'` | Redirect HTTP to HTTPS |
| `alb.ingress.kubernetes.io/certificate-arn` | ARN | SSL certificate |
| `alb.ingress.kubernetes.io/healthcheck-path` | `/health` | Health check path |
| `alb.ingress.kubernetes.io/healthcheck-interval-seconds` | `15` | Health check interval |

## Create NLB Service

For TCP/UDP traffic, use ServiceType LoadBalancer with NLB:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nlb-service
  namespace: default
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 443
    targetPort: 8443
```

## Verify ALB Creation

```bash
# Check Ingress status
kubectl get ingress -A

# Check ALB in AWS
aws elbv2 describe-load-balancers --region eu-west-1

# Check target groups
aws elbv2 describe-target-groups --region eu-west-1
```

## Troubleshooting

```bash
# View ALB controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller -f

# Check Ingress events
kubectl describe ingress my-app-ingress

# Verify ServiceAccount IRSA annotation
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml | grep role-arn
```

## Costs

- ALB: ~$16/month + $0.006 per LCU
- NLB: ~$32/month + $0.006 per NLCU
- Data processed: $0.006 per GB

Delete ALB Ingresses to avoid charges.
