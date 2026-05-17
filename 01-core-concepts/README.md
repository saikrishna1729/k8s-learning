# 🧱 01 - Core Concepts

> **This module teaches the building blocks.** After this, you'll understand what Pods are and how to keep them running reliably.

## ⏱️ Estimated Time: 1-2 hours | Difficulty: ⭐ Beginner

## 🎯 Problem This Solves

You have a Docker container and want to run it on Kubernetes. How do you describe it to Kubernetes? What keeps it running if it crashes? How do you update it without downtime?

## 📋 Prerequisites

- Docker understanding (what a container is)
- Local Kubernetes cluster running (`kubectl cluster-info`)
- kubectl installed

## Topics Covered
- Kubernetes Architecture (Control Plane + Worker Nodes)
- Pods — the atomic unit (smallest deployable unit)
- ReplicaSets — desired state (ensures N copies always running)
- Deployments — rollouts & rollbacks (updates without downtime)

## Key Learnings
- Pod IPs are ephemeral — change on every restart
- Liveness probe = is app alive? (restarts on fail)
- Readiness probe = is app ready for traffic? (removes from Service on fail)
- Deployments keep old ReplicaSets for rollback
- revisionHistoryLimit controls how many RS are kept

## 🔗 How This Connects to Module 02

After this module, you can create Pods and keep them running. But **Pod IPs change**, so users can't reliably access them.

**Module 02 (Services)** solves this: it gives Pods a **stable DNS name** so users can reach them even when Pods restart.

👉 **Next: [Module 02 — Services](../02-services/)**
