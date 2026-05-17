# 🚀 Microservices App — A Complete Kubernetes Project

This project ties together all modules (01-09) into a realistic 3-tier microservices application with Kubernetes.

## Architecture

```
┌─────────────────┐
│  Frontend Web   │  (nginx, static + React SPA)
│  (Deployment)   │
└────────┬────────┘
         │
    ┌────┴──────────────────────┐
    │                           │
┌───▼──────┐            ┌──────▼────┐
│  Backend │            │ API GW    │  (proxy for auth, rate-limit)
│   API    │            │ (Ingress) │
│(stateless)│           └───────────┘
└───┬──────┘
    │
┌───▼────────────────┐
│    PostgreSQL      │  (StatefulSet, persistent storage)
│   (Database)       │
└────────────────────┘
```

## Modules Used

| Module | Concept | Usage |
|--------|---------|-------|
| 01 — Core Concepts | Deployment, Pods, ReplicaSets | Frontend + Backend deployments |
| 02 — Services | ClusterIP, LoadBalancer | Internal services for backend, public LB for frontend |
| 03 — Ingress | Path/Host routing, TLS | Route `/api` to backend, `/` to frontend |
| 04 — Config | ConfigMaps, Secrets | Database connection strings, API keys |
| 05 — Helm | Charts, Values, Releases | Package entire app as Helm chart with env overrides |
| 06 — Scaling | HPA, VPA, Cluster Autoscaler | Auto-scale frontend/backend based on load; auto-scale cluster nodes |
| 07 — Observability | Prometheus, Grafana, Logging | Monitor frontend/backend/database health |
| 08 — Cloud | EKS, AKS, GKE | Deploy to AWS/Azure/GCP |
| 09 — Security | RBAC, Network Policies, PSA | Lock down Pod security, restrict traffic |

## Quick Start

### Deploy Manually (kubectl)

```bash
# Create namespace
kubectl create namespace microservices-app

# Deploy all resources
kubectl apply -f . -n microservices-app

# Verify
kubectl get all -n microservices-app
```

### Deploy via Helm

```bash
# Install chart
helm install my-app helm/ -n microservices-app --create-namespace
```

## Services

| Service | Type | Replicas | Port | Storage |
|---------|------|----------|------|---------|
| Frontend | Deployment | 2 | 80 | None |
| Backend API | Deployment | 2 | 8080 | None |
| PostgreSQL | StatefulSet | 1 | 5432 | 10Gi EBS |

## Files

- `frontend/` — nginx deployment + service
- `backend/` — app deployment with DB config + service
- `database/` — PostgreSQL StatefulSet + PVC + service
- `ingress.yaml` — Route / → frontend, /api → backend
- `config-and-secrets.yaml` — DB credentials, API keys
- `hpa-*.yaml` — Autoscaling policies
- `helm/` — Full Helm chart with values for dev/staging/prod

See individual `README.md` files in each subdirectory for details.
