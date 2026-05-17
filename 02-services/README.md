# 🌐 02 - Services

## Types
- ClusterIP  — internal only (default)
- NodePort   — external via Node IP (dev/test)
- LoadBalancer — external via Cloud LB (production)
- ExternalName — DNS alias to external service

## Key Learnings
- Services find Pods via LABEL SELECTORS
- Pod IPs change — Service DNS is stable
- DNS format: <service>.<namespace>.svc.cluster.local
- Endpoints update automatically as pods come/go
- 1 LoadBalancer = 1 Cloud LB = money! Use Ingress instead
