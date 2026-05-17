# 🚀 00 - Getting Started (Required Reading)

> **Start here BEFORE Module 01.** This section explains the foundational concepts using plain English and analogies.

**Time: 30 minutes** | **Difficulty: ⭐ Beginner (No K8s knowledge required)**

---

## 📚 What You'll Learn

This section answers the questions a complete beginner asks:

1. **[What is Kubernetes?](./01-what-is-kubernetes.md)** (5 min)
   - Why would I use it?
   - How does it solve real problems?

2. **[What is Docker & Containers?](./02-what-is-docker.md)** (5 min)
   - What's the difference between Docker and Kubernetes?
   - Do I need Docker to use Kubernetes?

3. **[What is a Pod?](./03-what-is-a-pod.md)** (5 min)
   - How is a Pod different from a container?
   - Why does Kubernetes use Pods?

4. **[What is kubectl?](./04-what-is-kubectl.md)** (3 min)
   - What tool is this?
   - How do I use it?

5. **[Kubernetes Architecture](./05-kubernetes-architecture.md)** (5 min)
   - What are Control Plane and Worker Nodes?
   - How do they work together?

6. **[YAML Explained](./06-yaml-explained.md)** (5 min)
   - What's this YAML syntax?
   - What does each section mean?

---

## ⏭️ After You Read This

You'll understand:
- ✅ What Kubernetes actually is (not just jargon)
- ✅ How Kubernetes solves real problems
- ✅ The relationship between Docker, containers, and Kubernetes
- ✅ Basic building blocks (Pod, Node, Cluster)
- ✅ How to read and understand YAML files
- ✅ What kubectl is and why you need it

**Then you're ready for Module 01: Core Concepts.**

---

## 🎯 Quick Summary (For Impatient People)

**Kubernetes in 30 seconds:**
- You have a Docker container (your app)
- You want to run it reliably on many machines
- Kubernetes automates: starting containers, restarting them if they crash, spreading them across servers, updating them without downtime
- You describe what you want in YAML files
- `kubectl` is your tool to tell Kubernetes what to do

**Pod in 30 seconds:**
- A Pod is Kubernetes' way of wrapping a container
- Usually 1 container = 1 Pod
- Think: Pod is the "Kubernetes unit", Container is the "Docker unit"

---

## 🔗 Navigation

**Next:** Read [What is Kubernetes?](./01-what-is-kubernetes.md)

**After Getting Started:** Go to [LEARNING-PATH.md](../LEARNING-PATH.md) → Start with [Module 01](../01-core-concepts/)

---

## ❓ Questions?

Each guide has:
- Plain English explanations
- Real-world analogies
- Visual diagrams (ASCII art)
- Examples

If something is still unclear, re-read that section—it's designed to be understood the first time.
