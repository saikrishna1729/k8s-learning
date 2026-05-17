# 📦 05 - Helm

## Key Concepts
- Chart    = Package of K8s YAML templates
- Release  = A deployed instance of a Chart
- Values   = Variables that customise the chart
- Revision = Version of a release (enables rollback)

## Helm vs Raw YAML
- One chart → many environments via value files
- No copy-pasting YAML across environments
- Built-in rollback with helm rollback
- Package and share via chart repositories

## Common Commands
```bash
helm create myapp
helm lint myapp/
helm template myapp/ -f values-dev.yaml
helm install myapp-dev myapp/ -f values-dev.yaml -n dev --create-namespace
helm upgrade myapp-dev myapp/ -f values-dev.yaml
helm rollback myapp-dev 1
helm history myapp-dev
helm list -A
helm uninstall myapp-dev -n dev
```
