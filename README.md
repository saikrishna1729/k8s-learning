# ⎈ Kubernetes Learning Journey

> A structured, hands-on learning repository for Kubernetes and Cloud-Native technologies.
> Built session by session — from Core Concepts to Production Cloud Deployments.

## 🗺️ Learning Roadmap

| # | Module | Topics | Status |
|---|--------|--------|--------|
| 01 | [Core Concepts](./01-core-concepts/) | Pods, Deployments, ReplicaSets | ✅ Done |
| 02 | [Services](./02-services/) | ClusterIP, NodePort, LoadBalancer | ✅ Done |
| 03 | [Ingress](./03-ingress/) | Path/Host routing, TLS, Controllers | ✅ Done |
| 04 | [Config Management](./04-config/) | ConfigMaps, Secrets | ✅ Done |
| 05 | [Helm](./05-helm/) | Charts, Values, Releases, Rollbacks | ✅ Done |
| 06 | [Scaling](./06-scaling/) | HPA, VPA, Cluster Autoscaler | 🔜 Next |
| 07 | [Observability](./07-observability/) | Prometheus, Grafana, Logging | 🔜 Next |
| 08 | [Cloud](./08-cloud/) | EKS, GKE, AKS | 🔜 Next |
| 09 | [Security](./09-security/) | RBAC, Network Policies | 🔜 Next |
| 10 | [Projects](./10-projects/) | Real-world microservices app | 🔜 Next |

## 🛠️ Local Setup

```bash
# Prerequisites
brew install kubectl helm orbstack

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

## 📋 Key Commands Cheatsheet

```bash
# Pods
kubectl get pods -A
kubectl describe pod <name>
kubectl logs <pod> -f
kubectl exec -it <pod> -- sh

# Deployments
kubectl apply -f deployment.yaml
kubectl rollout status deployment/<name>
kubectl rollout undo deployment/<name>
kubectl rollout history deployment/<name>

# Services
kubectl get svc
kubectl get endpoints

# Helm
helm install <release> <chart> -f values.yaml
helm upgrade <release> <chart> -f values.yaml
helm rollback <release> <revision>
helm list -A
```

## 🔧 Environment

- **Local Cluster:** OrbStack Kubernetes
- **kubectl version:** 1.28+
- **Helm version:** 3.x
- **OS:** macOS

## 📚 Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Helm Docs](https://helm.sh/docs/)
- [ArtifactHub (Charts)](https://artifacthub.io/)
- [K8s the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
