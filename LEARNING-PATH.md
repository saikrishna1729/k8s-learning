# 📚 Kubernetes Learning Path

A beginner's guide to working through this repository in the right order with clear prerequisites and connections.

---

## 🎯 Prerequisites

Before starting, ensure you have:
- **kubectl** (v1.28+) — `kubectl version --client`
- **Helm** (v3.x) — `helm version`
- **Docker** (understanding of containers) — basic `docker run` knowledge
- **Local K8s cluster** — OrbStack, minikube, or kind
  - Verify: `kubectl cluster-info`

---

## 📖 Module Progression

### **Phase 1: Core Concepts (Modules 01-03)**
*Learn the building blocks and how to expose Pods to traffic.*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **01** | [Core Concepts](./01-core-concepts/) | 1-2 hours | ⭐ Beginner | A Pod, then a Deployment with rolling updates |
| **02** | [Services](./02-services/) | 1-2 hours | ⭐ Beginner | Internal services, then external access |
| **03** | [Ingress](./03-ingress/) | 1 hour | ⭐ Beginner | HTTP routing rules for multiple services |

**Flow:** Pods → Deployments → Services (stable access) → Ingress (smart routing)

**After Phase 1, you can:**
- Deploy stateless apps
- Expose them to users
- Update apps without downtime

---

### **Phase 2: Configuration & Storage (Module 04)**
*Learn to manage app configuration and data that survives Pod restarts.*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **04** | [Config Management](./04-config/) | 2 hours | ⭐ Beginner | Deployments with env vars, configs, secrets, and persistent storage |

**Flow:** ConfigMaps → Secrets → PersistentVolumes/Claims → StatefulSets

**After Phase 2, you can:**
- Deploy apps with different configs per environment (dev/staging/prod)
- Store sensitive data securely
- Run databases that retain data across restarts

---

### **Phase 3: Packaging & Deployment (Module 05)**
*Learn to package and deploy apps at scale without copy-pasting YAML.*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **05** | [Helm](./05-helm/) | 1-2 hours | ⭐ Beginner | A complete application chart with dev/staging/prod configurations |

**Why Helm?** After Module 04, you might have 50+ YAML files. Helm avoids copy-paste and enables templating.

**After Phase 3, you can:**
- Package entire applications as reusable charts
- Deploy to multiple environments with one command
- Rollback instantly if something breaks

---

### **Phase 4: Production Operations (Modules 06-07)**
*Learn to keep apps running reliably at scale with observability.*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **06** | [Scaling](./06-scaling/) | 1-2 hours | ⭐⭐ Intermediate | Auto-scaling Pods and cluster nodes based on load |
| **07** | [Observability](./07-observability/) | 1-2 hours | ⭐⭐ Intermediate | Prometheus dashboards + logs to catch failures before users do |

**Flow:** HPA (scale Pods) → Cluster Autoscaler (scale nodes) → Metrics/Logs (see what's happening)

**After Phase 4, you can:**
- Handle traffic spikes automatically
- Detect and debug issues quickly
- Plan capacity based on real metrics

---

### **Phase 5: Cloud Deployment (Module 08)**
*Learn to deploy to production cloud services (EKS, AKS, or GKE).*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **08** | [Cloud](./08-cloud/) | 3-5 hours | ⭐⭐ Intermediate | A fully managed Kubernetes cluster with load balancers and persistent storage |

**Decision Tree:**
- **AWS shop?** → EKS (comprehensive guide)
- **Azure/Microsoft stack?** → AKS (minimal guide)
- **Google Cloud?** → GKE (minimal guide)

**After Phase 5, you can:**
- Run production applications in the cloud
- Leverage managed services (load balancers, databases)
- Handle compliance and security requirements

---

### **Phase 6: Security Hardening (Module 09)**
*Lock down your cluster so only authorized Pods can access what they need.*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **09** | [Security](./09-security/) | 2 hours | ⭐⭐⭐ Advanced | RBAC rules, network policies, and pod security standards |

**Why after cloud?** Security is important everywhere but often overlooked until production.

**After Phase 6, you can:**
- Prevent unauthorized access (RBAC)
- Block compromised Pods from attacking others (Network Policies)
- Enforce security best practices (Pod Security Admission)

---

### **Phase 7: Real-World Application (Module 10)**
*Put it all together: a 3-tier microservices app using all previous concepts.*

| Module | Topic | Time | Difficulty | What You'll Build |
|--------|-------|------|------------|------------------|
| **10** | [Projects](./10-projects/) | 2-3 hours | ⭐⭐⭐ Advanced | A complete microservices app (frontend + backend + database) with Helm chart |

**Integrates:** Deployments, Services, Ingress, ConfigMaps, Secrets, PVCs, Helm, HPA, Network Policies, RBAC

**After Phase 7, you can:**
- Architect and deploy production microservices
- Troubleshoot issues using all tools from modules 01-09
- Explain Kubernetes to your team

---

## 🗓️ Total Learning Time

| Phase | Time | Cumulative |
|-------|------|-----------|
| Phase 1 (01-03) | 3-4 hours | 3-4 hours |
| Phase 2 (04) | 2 hours | 5-6 hours |
| Phase 3 (05) | 1-2 hours | 6-8 hours |
| Phase 4 (06-07) | 2-4 hours | 8-12 hours |
| Phase 5 (08) | 3-5 hours | 11-17 hours |
| Phase 6 (09) | 2 hours | 13-19 hours |
| Phase 7 (10) | 2-3 hours | 15-22 hours |

**Total: 15-22 hours for complete learning path**

---

## 🚀 How to Use This Repository

### For Each Module:

1. **Read the README** — understand the problem and concepts
2. **Study the examples** — copy-paste the YAML files and run them
3. **Experiment locally** — modify examples, break things, fix them
4. **Read the guides** — detailed markdown files in each module
5. **Verify with CLI** — use kubectl commands to see what happened

### Example Learning Session:

```bash
# Module 01: Core Concepts
cd 01-core-concepts/

# Read the concepts
cat README.md

# Deploy the example
kubectl apply -f pods/pod.yaml
kubectl apply -f deployments/deployment.yaml

# Verify with kubectl
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Test rolling updates
kubectl set image deployment/my-app app=nginx:1.26
kubectl rollout status deployment/my-app
kubectl rollout history deployment/my-app
kubectl rollout undo deployment/my-app

# Clean up
kubectl delete -f .
```

---

## 💡 Tips for Success

### ✅ Do This:
- **Type commands yourself** — don't copy-paste blindly
- **Read error messages** — they're usually helpful
- **Break things intentionally** — delete Pods, scale to 0, etc.
- **Test on local cluster first** — before going to cloud
- **Complete Phase 1** — before skipping to Phase 5 (modules build on each other)

### ❌ Don't Do This:
- Skip Modules 01-03 — they're the foundation
- Use `kubectl delete` without understanding what you're deleting
- Deploy to production without doing Module 09 (Security)
- Memorize all commands — understand the concepts instead
- Rush through modules — one module per day is fine

---

## 🎓 Learning Outcomes

After completing this path, you'll be able to:

✅ **Deploy** applications to Kubernetes without manual steps  
✅ **Scale** apps automatically based on load  
✅ **Expose** apps securely to users  
✅ **Manage** configuration and secrets safely  
✅ **Monitor** app health with metrics and logs  
✅ **Update** apps with zero downtime  
✅ **Secure** clusters with RBAC and network policies  
✅ **Architect** microservices applications  
✅ **Deploy** to production cloud services (AWS, Azure, GCP)  
✅ **Troubleshoot** issues systematically  

---

## 🆘 When You Get Stuck

1. **Read the error message carefully** — it's usually the answer
2. **Check the module's guide** — e.g., `iam/irsa.md` for IAM issues
3. **Use `kubectl describe`** — shows events and error details
4. **Search the README** — concepts are indexed
5. **Try the examples as-is first** — before customizing
6. **Ask for help** — reference the module and what you tried

---

## 🔗 Cross-Module Dependencies

```
01 (Pods)
  ↓
02 (Services) — requires 01
  ↓
03 (Ingress) — requires 02
  ↓
04 (Config) — requires 01-03
  ↓
05 (Helm) — requires 01-04
  ↓
06 (Scaling) — requires 01-05
  ↓
07 (Observability) — requires 01-06
  ↓
08 (Cloud) — requires 01-07 + domain knowledge
  ↓
09 (Security) — requires 01-08
  ↓
10 (Projects) — requires 01-09 (integration)
```

**Bottom line:** Don't skip modules or reorder them. Each builds on previous ones.

---

## 📝 Module Checklists

Print these and check off as you go!

### Module 01: Core Concepts ☐
- [ ] Created a Pod manually
- [ ] Created a Deployment
- [ ] Scaled a Deployment up and down
- [ ] Rolled back a failed update
- [ ] Understood Pods vs Deployments vs ReplicaSets

### Module 02: Services ☐
- [ ] Created a ClusterIP Service
- [ ] Created a NodePort Service
- [ ] Accessed service via DNS
- [ ] Understood label selectors
- [ ] Saw endpoints auto-update

### Module 03: Ingress ☐
- [ ] Installed NGINX Ingress Controller
- [ ] Created path-based routing
- [ ] Created host-based routing
- [ ] Understood controller vs resource

### Module 04: Config Management ☐
- [ ] Created a ConfigMap
- [ ] Created a Secret
- [ ] Injected config via env and volumes
- [ ] Created a PVC and used it in a Pod
- [ ] Understood PV vs PVC vs StorageClass

### Module 05: Helm ☐
- [ ] Created a Helm chart
- [ ] Used different values files for dev/prod
- [ ] Performed helm upgrade and rollback
- [ ] Understood chart templating

### Module 06: Scaling ☐
- [ ] Created an HPA and watched Pods scale
- [ ] Understood Cluster Autoscaler scaling nodes
- [ ] Calculated cost of over-provisioning

### Module 07: Observability ☐
- [ ] Installed Prometheus and Grafana
- [ ] Viewed metrics in Prometheus
- [ ] Created a Grafana dashboard
- [ ] Understood metrics vs logs

### Module 08: Cloud ☐
- [ ] Created a Kubernetes cluster on EKS (or AKS/GKE)
- [ ] Deployed an app to cloud cluster
- [ ] Used cloud load balancer
- [ ] Understood IAM roles for service accounts

### Module 09: Security ☐
- [ ] Created RBAC roles and bindings
- [ ] Applied network policies
- [ ] Labeled namespace for PSA
- [ ] Tested `kubectl auth can-i`

### Module 10: Projects ☐
- [ ] Deployed microservices app locally
- [ ] Deployed microservices app to cloud
- [ ] Integrated all concepts (01-09)

---

## 🎉 Next Steps After Completion

Once you've completed the learning path:

1. **Build something real** — deploy your own app following the patterns
2. **Read the official Kubernetes docs** — you're ready for advanced topics
3. **Explore ecosystem tools** — service mesh (Istio), CI/CD (ArgoCD), etc.
4. **Join K8s communities** — CNCF, Kubernetes Slack, etc.
5. **Keep experimenting** — Kubernetes is best learned by doing

Happy learning! 🚀
