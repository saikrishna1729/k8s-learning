# 🔀 03 - Ingress

> **This module routes traffic intelligently.** One LoadBalancer can serve multiple services based on hostname/path rules.

## ⏱️ Estimated Time: 1 hour | Difficulty: ⭐ Beginner

## 🎯 Problem This Solves

From Module 02: You have Services, but each LoadBalancer costs money. You want to route `myapp.com/api` to backend and `myapp.com/` to frontend using **one LoadBalancer**.

**Answer:** Ingress routes traffic based on domain and path.

## 📋 Prerequisites

- Modules 01-02 (Pods and Services)
- kubectl access to a cluster
- NGINX Ingress Controller installed (see CLI Commands below)

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

## CLI Commands

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

# Verify installation
kubectl get pods -n ingress-nginx

# View Ingress
kubectl get ingress -A
kubectl describe ingress <ingress-name>
```

## 🔗 How This Connects to Module 04

After this module, you have routing working! But **apps need configuration** (database URLs, API keys, feature flags) that differs per environment.

**Module 04 (Config Management)** solves this: it shows how to inject ConfigMaps and Secrets into Pods, plus storage for databases.

👉 **Next: [Module 04 — Config Management](../04-config/)**
