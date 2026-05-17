# 🌐 02 - Services

> **This module solves the "unreachable Pods" problem.** Services give Pods a stable DNS name and load balance traffic across replicas.

## ⏱️ Estimated Time: 1-2 hours | Difficulty: ⭐ Beginner

## 🎯 Problem This Solves

From Module 01: You have 3 Pod replicas running your app, but Pod IPs change when they restart. How do users reliably connect? How does traffic reach all 3 Pods?

**Answer:** Services provide stable DNS + automatic load balancing.

## 📋 Prerequisites

- Module 01 (Core Concepts) — understand Pods and Deployments
- kubectl access to a cluster

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

## 🔗 How This Connects to Module 03

After this module, each service has a LoadBalancer. But **each LoadBalancer costs money**. If you have 10 services, that's 10 LoadBalancers!

**Module 03 (Ingress)** solves this: it routes multiple services through **ONE LoadBalancer** based on hostname and path.

👉 **Next: [Module 03 — Ingress](../03-ingress/)**
