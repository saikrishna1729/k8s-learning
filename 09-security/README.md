# 🔐 Security

> **This module locks down your cluster.** Only authorized Pods access what they need, and traffic between Pods is explicitly allowed.

## ⏱️ Estimated Time: 2 hours | Difficulty: ⭐⭐⭐ Advanced

## 🎯 Problem This Solves

From Module 08: Your app is in the cloud. But **it's wide open**—any Pod can talk to any other Pod, default ServiceAccounts have excess permissions, and anyone with `kubectl` access can read Secrets.

**Answer:** RBAC (who can do what), Network Policies (which Pods can talk), Pod Security Admission (container hardening).

## 📋 Prerequisites

- Modules 01-08 (full stack + cloud deployment)
- kubectl access to a cluster
- Understanding of least-privilege principle

## Key Concepts

- **RBAC (Role-Based Access Control)** — Defines who can do what in Kubernetes. Uses Roles (namespace-scoped) and ClusterRoles (cluster-wide), bound to ServiceAccounts, Users, or Groups.
- **Network Policies** — Firewall rules for Pod-to-Pod communication. Default behavior: all Pods can talk to all Pods. Network Policies restrict this.
- **Pod Security Admission (PSA)** — Enforces Pod security standards at namespace level via labels. Replaces deprecated PSP (Pod Security Policy).
- **ServiceAccount** — Kubernetes identity for Pods. Every Pod runs as a ServiceAccount; default is `default` SA in each namespace.
- **RBAC Verbs** — Actions: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`, `deletecollection`, `exec`, `logs`, `portforward`, etc.

## Key Learnings

- **Never use default ServiceAccount in production** — create a dedicated SA per app with minimal permissions. Default SA often has excess privileges.
- **Network Policies require a network plugin that supports them** — OrbStack, Calico, Weave support them. Not all CNIs do. Policy order matters: first match wins.
- **Pod Security Admission labels are namespace-wide** — label the namespace once; all Pods inherit. `restricted` is strict (non-root, read-only FS, no privileg). `baseline` allows some common patterns. `privileged` allows everything.
- **Roles vs ClusterRoles** — Roles are namespace-scoped (get/list pods in one namespace). ClusterRoles are cluster-wide (read all configmaps in all namespaces). ClusterRoles are also used for non-namespaced resources (nodes, PVs, etc).
- **Test RBAC with `kubectl auth can-i`** — debug permission issues: `kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa`.
- **apiGroups in RBAC** — Most resources are in `""` (empty string). Extensions: `apps`, `batch`, `extensions`. CRDs have their own group (e.g., `monitoring.coreos.com`).

## CLI Commands

```bash
# Check RBAC permissions
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa
kubectl auth can-i delete nodes --as=system:serviceaccount:default:my-sa

# List all roles and rolebindings
kubectl get roles,rolebindings -A
kubectl get clusterroles,clusterrolebindings

# View specific role/clusterrole
kubectl get role my-role -o yaml
kubectl describe clusterrole cluster-admin

# Create role from command (dry-run to see YAML)
kubectl create role pod-reader --verb=get,list,watch --resource=pods --dry-run=client -o yaml

# Apply Network Policies
kubectl apply -f network-policy.yaml
kubectl get networkpolicies -A

# Label namespace for Pod Security Admission
kubectl label namespace default pod-security.kubernetes.io/enforce=baseline --overwrite
kubectl label namespace default pod-security.kubernetes.io/audit=restricted --overwrite
kubectl label namespace default pod-security.kubernetes.io/warn=restricted --overwrite
```

## 🔗 How This Connects to Module 10

After this module, you understand all the pieces: networking, storage, scaling, observability, cloud, and security.

**Module 10 (Projects)** is the capstone—a 3-tier microservices app that integrates ALL concepts from modules 01-09. You'll deploy it locally first, then to the cloud.

👉 **Next: [Module 10 — Projects](../10-projects/)**