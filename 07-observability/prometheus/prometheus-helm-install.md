# Install Prometheus Stack

This guide installs `kube-prometheus-stack`, which includes Prometheus, Grafana, AlertManager, and exporters.

## Prerequisites

- Helm 3.x
- kubectl access to cluster

## Install

```bash
# Add Prometheus community Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install the stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values.yaml
```

## Verify

```bash
# Check all components deployed
kubectl get all -n monitoring

# Check Prometheus is scraping targets
kubectl get prometheus -n monitoring
kubectl get servicemonitor -n monitoring

# View Prometheus logs
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus -f
```

## Access Prometheus

```bash
# Port-forward to Prometheus (default port 9090)
kubectl port-forward -n monitoring svc/kube-prometheus-prometheus 9090:9090

# Open browser: http://localhost:9090
# Go to Status > Targets to see scrape jobs
```

## Add Custom Scrape Targets

Use `ServiceMonitor` resource (Prometheus Operator syntax):

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: default
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

Apply it and Prometheus will automatically add it to scrape config:

```bash
kubectl apply -f servicemonitor.yaml
# Prometheus reloads config within ~1 minute
```

## Retention & Storage

Default: Prometheus retains 10GB of data (~15 days on busy cluster).

To change retention, edit the Prometheus resource:

```bash
kubectl edit prometheus -n monitoring kube-prometheus-kube-prom-prometheus

# Add or edit spec.retention
spec:
  retention: 30d
  storageSpec:
    volumeClaimTemplate:
      spec:
        storageClassName: ebs-gp3
        accessModes: [ ReadWriteOnce ]
        resources:
          requests:
            storage: 50Gi
```

## Uninstall

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```
