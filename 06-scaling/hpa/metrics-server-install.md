# Install Metrics Server

Metrics Server is required for HPA to work. It runs in `kube-system` and collects resource metrics from kubelet.

## Install

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Verify installation:

```bash
kubectl get deploy -n kube-system metrics-server
kubectl logs -n kube-system -l k8s-app=metrics-server
```

## Verify Metrics

Once metrics-server is running (wait ~30 seconds), check if metrics are available:

```bash
# View node metrics
kubectl top nodes

# View pod metrics in all namespaces
kubectl top pods -A

# View pod metrics in a specific namespace
kubectl top pods -n default
```

If `kubectl top` returns "no metrics found", wait a few more seconds for metrics-server to scrape kubelet data.

## For Cloud Managed Services

- **EKS:** metrics-server is installed by default
- **AKS:** metrics-server is installed by default
- **GKE:** metrics-server is installed by default

You only need to install metrics-server manually on self-managed clusters.
