# Access Grafana Dashboard

## Port-forward

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

## Login

- **URL:** http://localhost:3000
- **Username:** admin
- **Password:** prom-operator (default from kube-prometheus-stack Helm chart)

## Change Password

1. Login with default credentials
2. Click avatar (top-right) > Preferences
3. Change password

Or via kubectl:

```bash
# Patch the secret directly (base64 encoded)
kubectl patch secret -n monitoring kube-prometheus-grafana -p \
  '{"data": {"admin-password": "'$(echo -n 'mynewpassword' | base64 -w0)'"}}'

# Restart Grafana to reload
kubectl rollout restart deployment -n monitoring kube-prometheus-grafana
```

## Add Data Source

Prometheus is pre-configured in kube-prometheus-stack. To verify:

1. Click Configuration (gear icon) > Data Sources
2. You should see "Prometheus" already configured at `http://kube-prometheus-prometheus:9090`

To add other data sources (Loki for logs, etc.):

1. Click Configuration > Data Sources > Add
2. Select type, fill in URL, click Save & Test

## Create Dashboard

1. Click + (top-left) > Dashboard
2. Click "Add new panel"
3. In "Metrics" field, enter PromQL query (e.g., `up{job="prometheus"}`)
4. Click "Run queries"
5. Customize visualization type, title, etc.
6. Click "Apply" to add to dashboard
7. Save dashboard

## Import Pre-built Dashboards

Grafana has thousands of community dashboards at https://grafana.com/grafana/dashboards/

1. Click + (top-left) > Import
2. Paste dashboard ID or JSON
3. Select Prometheus as data source
4. Click Import

Popular dashboard IDs:
- `1860` — Node Exporter Full (node metrics)
- `3119` — Kubernetes cluster monitoring (cluster-level)
- `6417` — Kubernetes Cluster Monitoring (another variation)
