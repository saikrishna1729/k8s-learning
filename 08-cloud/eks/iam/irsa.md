# IRSA — IAM Roles for Service Accounts

IRSA allows Pods to assume IAM roles and access AWS services securely using temporary STS tokens, without embedding credentials in the Pod.

## How IRSA Works

1. Pod runs as ServiceAccount
2. ServiceAccount has OIDC provider annotation with IAM role ARN
3. When Pod requests AWS SDK credentials, the OIDC token is exchanged for STS temporary credentials
4. Temporary credentials expire (default 1 hour)
5. Pod uses temp credentials to call AWS APIs

Benefits:
- No long-lived credentials in Pod environment
- Fine-grained permissions per service
- Audit trail in CloudTrail
- Automatic credential refresh

## Setup IRSA

### Prerequisites

- EKS cluster with OIDC provider (auto-created if using eksctl or Terraform)
- AWS CLI
- kubectl

### Step 1: Create IAM Role with Trust Relationship

```bash
CLUSTER_NAME="my-cluster"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="eu-west-1"
SERVICE_ACCOUNT_NAME="my-app"
NAMESPACE="default"

# Create trust policy
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION}.amazonaws.com/id/EXAMPLEID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${REGION}.amazonaws.com/id/EXAMPLEID:sub": "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}",
          "oidc.eks.${REGION}.amazonaws.com/id/EXAMPLEID:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name ${CLUSTER_NAME}-${SERVICE_ACCOUNT_NAME}-role \
  --assume-role-policy-document file:///tmp/trust-policy.json
```

### Step 2: Attach Permissions

```bash
# Attach a policy (e.g., S3 read-only)
aws iam attach-role-policy \
  --role-name ${CLUSTER_NAME}-${SERVICE_ACCOUNT_NAME}-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

### Step 3: Annotate ServiceAccount

Create a ServiceAccount with the role ARN annotation:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-cluster-my-app-role
```

Apply:

```bash
kubectl apply -f serviceaccount.yaml
```

### Step 4: Deploy Pod with ServiceAccount

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: default
spec:
  serviceAccountName: my-app
  containers:
  - name: app
    image: my-app:latest
    env:
    - name: AWS_ROLE_ARN
      value: arn:aws:iam::123456789012:role/my-cluster-my-app-role
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

### Automatic via eksctl

Faster alternative:

```bash
eksctl create iamserviceaccount \
  --name ${SERVICE_ACCOUNT_NAME} \
  --namespace ${NAMESPACE} \
  --cluster ${CLUSTER_NAME} \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve
```

## Testing

### Test from Pod

```bash
# Deploy a test pod
kubectl run -it --rm aws-cli \
  --image=amazon/aws-cli:latest \
  --serviceaccount=my-app \
  --overrides='{"spec": {"containers": [{"name": "aws-cli", "args": ["sts", "get-caller-identity"]}]}}' \
  -- aws sts get-caller-identity
```

Should output the role ARN, not your IAM user.

### Verify Credentials

```bash
# From inside pod
env | grep AWS_
curl -H "Authorization: Bearer $(cat $AWS_WEB_IDENTITY_TOKEN_FILE)" \
  https://sts.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15
```

## Common Issues

| Problem | Solution |
|---------|----------|
| Pod can't assume role | Verify ServiceAccount annotation matches role ARN |
| Credentials expire too fast | Increase token lifetime in OIDC provider settings (max 1 hour) |
| Audit log shows deny | Check IAM policy is attached to role |
| Pod can't find token file | Ensure `AWS_WEB_IDENTITY_TOKEN_FILE` env var is set |

## Security Best Practices

- **Least privilege:** attach minimal policy (not AdministratorAccess)
- **Namespace isolation:** one role per namespace/service to prevent lateral movement
- **Audit:** enable CloudTrail for all assume-role calls
- **Rotation:** update trust policy if cluster changes regions
