# 🧱 01 - Core Concepts

## Topics Covered
- Kubernetes Architecture (Control Plane + Worker Nodes)
- Pods — the atomic unit
- ReplicaSets — desired state
- Deployments — rollouts & rollbacks

## Key Learnings
- Pod IPs are ephemeral — change on every restart
- Liveness probe = is app alive? (restarts on fail)
- Readiness probe = is app ready for traffic? (removes from Service on fail)
- Deployments keep old ReplicaSets for rollback
- revisionHistoryLimit controls how many RS are kept
