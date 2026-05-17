# 📈 Scaling

> **This module handles traffic surges automatically.** Your app scales horizontally (more Pods) and vertically (bigger nodes) without manual intervention.

## ⏱️ Estimated Time: 1-2 hours | Difficulty: ⭐⭐ Intermediate

## 🎯 Problem This Solves

From Module 05: Your app is deployed and working. Then a traffic spike hits—your 2 Pod replicas are maxed out, users see slowness/timeouts. **You need automation.**

**Answer:** HPA scales Pods, Cluster Autoscaler scales nodes, all based on metrics.

## 📋 Prerequisites

- Modules 01-05 (full stack)
- kubectl access to a cluster with metrics-server (auto-installed in cloud services)

## Key Concepts

- **Horizontal Pod Autoscaler (HPA)** — Automatically scales the number of replicas based on metrics (CPU, memory, custom metrics). Requires metrics-server to gather data.
- **Vertical Pod Autoscaler (VPA)** — Automatically adjusts CPU/memory requests and limits for containers based on actual usage. Runs in three modes: Off, Initial, Recreate, Auto.
- **Cluster Autoscaler** — Automatically provisions or deprovisions cluster nodes based on unschedulable Pods and resource utilization. Different implementations per cloud provider (EKS, AKS, GKE).
- **Karpenter** — Modern AWS alternative to Cluster Autoscaler; more flexible and feature-rich (consolidation, weights, flexible node templates).

## Key Learnings

- **HPA watches only metrics from running Pods** — if Pods are pending (no node capacity), HPA can't help; Cluster Autoscaler must kick in first.
- **Never run HPA + VPA together targeting the same metric** — both trying to adjust CPU/memory causes oscillation and unpredictable behavior. Use HPA for replicas, VPA for right-sizing.
- **VPA has a cold-start problem** — initial recommendations take time to gather; use `Initial` or `Recreate` mode carefully in production.
- **Cluster Autoscaler lag** — scale-out is slow (~5-10 min for new node to be ready); scale-in is even slower (15-20 min). Karpenter scales faster and more efficiently.
- **Costs add up fast** — every new node (even on-demand) incurs hourly charges; over-provisioning `maxReplicas` on HPA and high min node count drains budgets.
- **HPA metrics come from metrics-server** — must be installed in kube-system for HPA to work. Cloud managed services may install it automatically (EKS does).

## CLI Commands

```bash
# Install metrics-server (required for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check if metrics are available
kubectl top nodes
kubectl top pods -A

# View current HPA status
kubectl get hpa -A
kubectl describe hpa my-hpa

# View VPA recommendations (if installed)
kubectl describe vpa my-vpa

# Scale manually (for testing)
kubectl scale deployment my-app --replicas 5
```

## 🔗 How This Connects to Module 07

After this module, your app auto-scales. But **you can't see what's happening**—is it scaling for the right reason? Is there a memory leak? Are users experiencing slowness?

**Module 07 (Observability)** solves this: it shows metrics (Prometheus), dashboards (Grafana), and logs to understand what's really happening.

👉 **Next: [Module 07 — Observability](../07-observability/)**
