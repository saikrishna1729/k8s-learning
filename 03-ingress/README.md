# 🔀 03 - Ingress

## Key Concepts
- Ingress Resource = WHAT to do (your routing rules)
- Ingress Controller = HOW to do it (nginx/traefik doing the work)
- 1 LB for ALL services = massive cost saving

## Routing Types
- Path-based: myapp.com/api → api-service
- Host-based: api.myapp.com → api-service

## pathType
- Exact  → /api matches ONLY /api
- Prefix → /api matches /api, /api/users, /api/v2

## Install NGINX Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml
```
