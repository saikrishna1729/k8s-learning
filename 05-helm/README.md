# 📦 05 - Helm

> **This module packages your app for reuse.** Deploy the same Helm chart to dev/staging/prod with one command each.

## ⏱️ Estimated Time: 1-2 hours | Difficulty: ⭐ Beginner

## 🎯 Problem This Solves

From Module 04: You have 50+ YAML files (deployments, services, configmaps, secrets). You copy-paste them for each environment and manually change values. **This is error-prone.**

**Answer:** Helm templating—one chart, many environments.

## 📋 Prerequisites

- Modules 01-04 (Full stack: Pods through Secrets)
- Helm installed (`helm version`)

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

## 🔗 How This Connects to Module 06

After this module, you can deploy your app reliably. But **what happens when traffic increases?** Your Pods will get overloaded and fail.

**Module 06 (Scaling)** solves this: it auto-scales Pods when CPU goes high, and auto-scales cluster nodes when Pods can't fit.

👉 **Next: [Module 06 — Scaling](../06-scaling/)**
