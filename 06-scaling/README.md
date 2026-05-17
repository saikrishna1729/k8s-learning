# 📈 Scaling

> **This module handles traffic surges automatically.** Your app scales horizontally (more Pods) and vertically (bigger nodes) without manual intervention.

## ⏱️ Estimated Time: 1-2 hours | Difficulty: ⭐⭐ Intermediate

## 🎯 Problem This Solves

From Module 05: Your app is deployed and working. Then a traffic spike hits—your 2 Pod replicas are maxed out, users see slowness/timeouts. **You need automation.**

**Answer:** Learn three levels of scaling:
1. **HPA** (easy): scale Pods horizontally
2. **Cluster Autoscaler** (medium): scale cluster nodes when Pods don't fit
3. **VPA** (advanced): vertically optimize Pod resources

## 📋 Prerequisites

- Modules 01-05 (full stack)
- kubectl access to a cluster with metrics-server (auto-installed in cloud services)

---

## 1️⃣ Horizontal Pod Autoscaler (HPA) — Start Here

**What it does:** Scales number of Pods when CPU/memory exceeds threshold.

**When to use:** Almost always—your first scaling tool.

**How it works:**
1. metrics-server continuously monitors Pod CPU/memory
2. HPA checks every 15 seconds: "are Pods above 70% CPU?"
3. If yes → spawn more Pods
4. If no for 5 min → delete Pods

**Key Learning:** HPA is **Pod-level** scaling. If no node capacity, Pods go Pending. That's when Cluster Autoscaler kicks in.

**Example:**
```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70  # scale when avg CPU > 70%
```

**Prerequisites:** metrics-server installed (cloud services install it auto).

---

## 2️⃣ Cluster Autoscaler — Scale Nodes

**What it does:** Scales cluster nodes when Pods can't fit.

**When to use:** When HPA wants to scale Pods but there's no node capacity.

**Scenario:**
```
Traffic spike hits
  ↓
HPA tries to create 5 new Pods
  ↓
Cluster is full, Pods go Pending
  ↓
Cluster Autoscaler sees Pending Pods
  ↓
Provisions new node
  ↓
Pending Pods get scheduled
```

**Key Learning:** HPA and Cluster Autoscaler work together. HPA scales Pods, Cluster Autoscaler scales nodes.

**Gotcha:** Scale-out is slow (~5-10 min for new node ready). Plan for spike buffer.

**Cloud Provider Setup:** Different for EKS (IAM), AKS (managed identity), GKE (service account). See Module 08.

---

## 3️⃣ Vertical Pod Autoscaler (VPA) — Advanced

**What it does:** Adjusts CPU/memory **requests** based on actual usage.

**When to use:** After HPA, when Pods are wasting resources (requesting 500m CPU but using 50m).

**Why it's different from HPA:**
- HPA scales **number of Pods** (horizontal)
- VPA scales **Pod resources** (vertical)

**Problem:** If you request too much (500m) or too little (50m):
- Too much → waste money
- Too little → Pods evicted when node pressure happens

**VPA solves it:** "You're requesting 500m CPU but using 50m. Let me adjust to 100m to be safe."

**Key Learning:** **Never use HPA + VPA together on same metric**. Both fighting causes oscillation:
```
HPA: "scale to 10 Pods due to high CPU"
VPA: "reduce resource requests to free up CPU"
Result: chaos
```

**Use case:** Use HPA for replicas + VPA for requests (different metrics).

---

## 📚 Key Concepts

- **metrics-server** — collects metrics from Pods (required for HPA)
- **Desired state** — you say "max 10 Pods, target 70% CPU", Kubernetes enforces it
- **Scale lag** — HPA: ~15 sec response. Cluster Autoscaler: ~5-10 min (slow!)
- **Karpenter** — modern AWS replacement for Cluster Autoscaler (faster, smarter)

## ⚠️ Critical: Costs

**Every new node costs money.** Estimate:
- t3.medium: $0.03/hour = $20/month
- t3.large: $0.06/hour = $40/month

**Over-provisioning kills budgets:**
- `maxReplicas: 100` → might scale to 100 Pods = 20 nodes = $400/month
- `maxReplicas: 10` → stays reasonable = ~2 nodes = $40/month

**Set appropriate limits:**
- maxReplicas = reasonable peak (not "what if viral?")
- minReplicas = minimum for always-on
- Monitor CloudWatch/GCP/Azure billing weekly

## Key Learnings

- **HPA watches only running Pods** — if Pending (no node capacity), HPA can't fix it. Cluster Autoscaler must step in.
- **Cluster Autoscaler is slow** — scale-out ~5-10 min, scale-in ~15-20 min. Design for this lag.
- **Never combine HPA + VPA on same metric** — causes oscillation and unpredictable behavior.
- **metrics-server is required** — install before HPA. Cloud services (EKS, AKS, GKE) auto-install it.
- **Costs escalate quickly** — 1 extra node = $20-40/month. 10 extra nodes = $200-400/month.
- **Karpenter is better than Cluster Autoscaler** — AWS only, faster scaling, consolidation. Consider for production.

## CLI Commands — Progressive Order

### Step 1: Install Metrics Server (Required)
```bash
# Install metrics-server (required for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify it's running
kubectl get pods -n kube-system | grep metrics-server

# Check if metrics are available (wait ~30 seconds)
kubectl top nodes
kubectl top pods -A
```

### Step 2: HPA (Horizontal Pod Autoscaler)
```bash
# View HPA status
kubectl get hpa -A

# Describe an HPA
kubectl describe hpa my-hpa

# Create HPA for a Deployment (max 10 replicas, target 70% CPU)
kubectl autoscale deployment my-app --min=2 --max=10 --cpu-percent=70

# Watch HPA in action
kubectl get hpa -w
```

### Step 3: Cluster Autoscaler
```bash
# View logs (depends on provider: EKS, AKS, GKE)
# For EKS:
kubectl logs -n kube-system -l app=cluster-autoscaler -f

# For AKS:
kubectl logs -n kube-system -l k8s-app=cluster-autoscaler -f

# Check nodes (watch as they auto-scale)
kubectl get nodes -w
```

### Step 4: VPA (Vertical Pod Autoscaler) — Advanced
```bash
# View VPA recommendations
kubectl describe vpa my-vpa

# Check VPA status (if installed)
kubectl get vpa -A
```

### Manual Testing
```bash
# Scale manually (for testing without auto-scaling)
kubectl scale deployment my-app --replicas 5

# Monitor resource usage
kubectl top pods -A
```

## 🔗 How This Connects to Module 07

After this module, your app auto-scales. But **you can't see what's happening**—is it scaling for the right reason? Is there a memory leak? Are users experiencing slowness?

**Module 07 (Observability)** solves this: it shows metrics (Prometheus), dashboards (Grafana), and logs to understand what's really happening.

👉 **Next: [Module 07 — Observability](../07-observability/)**
