# 📊 Observability

> **This module makes your infrastructure visible.** See metrics, logs, and events to understand what's happening and catch problems before users report them.

## ⏱️ Estimated Time: 1-2 hours | Difficulty: ⭐⭐ Intermediate

## 🎯 Problem This Solves

From Module 06: Your app auto-scales. But **how do you know if it's healthy?** Is CPU actually high or is something else wrong? Are database connections leaking? Did that deploy cause a latency spike?

**Answer:** Prometheus metrics, Grafana dashboards, and aggregated logs.

## 📋 Prerequisites

- Modules 01-06 (full stack with scaling)
- kubectl access to a cluster
- Helm (for installing Prometheus/Grafana)

## Key Concepts

- **Metrics** — Time-series data (CPU, memory, request count). Prometheus scrapes targets and stores them. Queryable via PromQL.
- **Logs** — Event streams (application output, API requests). Collected by agents (Fluentd, Fluent Bit) and aggregated (Elasticsearch, Loki, CloudWatch).
- **Traces** — Distributed request flows across microservices. Less common in beginner clusters but essential for microservices debugging.
- **Prometheus** — Metrics collection system: scrapes HTTP `/metrics` endpoints, stores time-series data, enables alerting.
- **Grafana** — Visualization and dashboarding. Connects to Prometheus (and other data sources) to display metrics and create dashboards.
- **Observability Stack** — Prometheus + Grafana + alertmanager + kube-state-metrics + node-exporter (packaged together in `kube-prometheus-stack` Helm chart).

## Key Learnings

- **Prometheus is pull, not push** — scrape intervals default to 30s; data is ~5 min stale by default. Use Pushgateway for short-lived jobs.
- **Metrics are expensive at scale** — high cardinality labels (user ID, request ID) explode storage; filter or aggregate them.
- **Default Grafana login** — `admin` / `prom-operator` (when installed via kube-prometheus-stack Helm chart).
- **Pod logs are ephemeral** — lost when Pod dies. Always aggregate logs; rely on `kubectl logs` only for debugging single Pods.
- **ServiceMonitor is Prometheus Operator syntax** — only works if Prometheus Operator is running (part of kube-prometheus-stack). Raw Prometheus uses `prometheus.yml` scrape configs.
- **Storage is critical** — Prometheus data grows ~1-2 GB/day on a busy cluster; plan persistent volumes and retention policies.

## CLI Commands

```bash
# Install prometheus + grafana + alertmanager stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# Verify installation
kubectl get all -n monitoring

# Port-forward to Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-prometheus 9090:9090

# Port-forward to Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80

# Query Prometheus API
curl http://localhost:9090/api/v1/targets

# View logs from all pods in a namespace
kubectl logs -f deployment/my-app -n default

# Stream logs from multiple pods
kubectl logs -f -l app=my-app -n default --all-containers=true
```

## 🔗 How This Connects to Module 08

After this module, your app is production-ready locally. But **local clusters are for learning**—you need a real, managed Kubernetes service.

**Module 08 (Cloud)** covers EKS (AWS), AKS (Azure), and GKE (Google)—managed services that handle control plane, backups, and multi-zone resilience.

👉 **Next: [Module 08 — Cloud](../08-cloud/)**
