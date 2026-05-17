# 🔐 04 - Config Management

## ConfigMap vs Secret
- ConfigMap = non-sensitive config (stored as plain text in etcd)
- Secret = sensitive config (stored as base64 in etcd)
- Base64 is NOT encryption — anyone can decode it!
- Real security = RBAC + etcd encryption at rest

## Injection Patterns
1. env / envFrom   → needs pod RESTART to pick up changes
2. Volume Mount    → updates AUTOMATICALLY (~60s sync)

## Production Secret Management
- Never commit Secret YAMLs to git!
- Use External Secrets Operator + AWS SSM / HashiCorp Vault
- Always mount secrets as readOnly volumes
- Restrict access with RBAC
