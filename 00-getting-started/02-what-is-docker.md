# 🐳 What is Docker & Containers?

**Plain English:** Docker lets you package your app with all its dependencies into a box so it runs the same everywhere.

---

## The Problem Docker Solves

### Without Docker:
```
Developer on Mac: "Works on my machine!"
QA on Linux: "Doesn't work on mine!"
DevOps on Windows: "Doesn't work here either!"

Why? Different operating systems, different Python versions, different libraries installed
```

### With Docker:
```
Developer: "I packaged my app in a Docker container"
QA: "Runs perfectly!"
DevOps: "Perfect!"

Why? The app + all dependencies are bundled together. Same everywhere.
```

---

## What is a Container? (Simple Explanation)

**A container is like a lightweight virtual machine for your app.**

### Virtual Machine vs Container:

```
VIRTUAL MACHINE:
┌─────────────────────┐
│ Windows OS          │
│ 3 GB RAM            │
│ Virtualizes CPU     │
│ Slow to start       │
│ Heavy (GB)          │
└─────────────────────┘

CONTAINER:
┌─────────────────────┐
│ Your App            │
│ + Dependencies      │
│ + Linux libs        │
│ Shares kernel       │
│ Fast to start       │
│ Light (MB)          │
└─────────────────────┘
```

**Key difference:** Container shares the OS kernel, VM has its own OS. Containers are faster and smaller.

---

## What is Docker?

Docker is a tool that creates and runs containers.

### How Docker Works:

```
Step 1: You write your app (Python, Node, Java, etc.)
Step 2: You create a Dockerfile (recipe for the container)
Step 3: Docker builds the container (packages app + dependencies)
Step 4: Docker runs the container (your app is isolated but can access the network)
```

### Example Dockerfile:

```dockerfile
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

Translation:
- Start with Python 3.9 base image
- Set working directory to /app
- Copy my code into the container
- Install Python dependencies
- When container starts, run my app

---

## Docker Image vs Container

### Docker Image:
- **Like:** A recipe or blueprint
- **Purpose:** Template for creating containers
- **Stored:** On disk (can be pushed to Docker Hub)
- **Example:** `nginx:1.25` (the recipe)

### Docker Container:
- **Like:** Running instance of the recipe
- **Purpose:** Actually running your app
- **Stored:** In memory (running process)
- **Example:** Running instance of nginx (the cooked dish)

**Analogy:** Image = cake recipe, Container = actual cake

---

## Docker Hub (The App Store for Containers)

Just like Google Play has apps, Docker Hub has container images.

### Popular Images:
- `nginx:1.25` — web server
- `postgres:15` — database
- `python:3.9` — Python runtime
- `node:18` — Node.js runtime

You can download these and run them instantly:

```bash
# Run a web server
docker run nginx:1.25

# Run a database
docker run postgres:15

# Run Python
docker run python:3.9
```

---

## Docker vs Kubernetes: Clear Difference

| Aspect | Docker | Kubernetes |
|--------|--------|-----------|
| **What** | Runs one container on one machine | Manages many containers across many machines |
| **Scale** | "Run my app" | "Run 10 copies of my app" |
| **Restart** | Manual | Automatic |
| **Update** | Manual | Automatic |
| **Scaling** | Manual | Automatic |
| **Learning** | Easy (a few hours) | Medium (days) |

### Relationship:
```
Docker = How you package your app
Kubernetes = How you manage packaged apps at scale
```

**Docker is a prerequisite for Kubernetes.** Kubernetes runs Docker containers (or other container runtimes).

---

## Do You Need to Learn Docker First?

**Short answer:** Not in detail, but here's what you need to know:

### Minimum Docker Knowledge:
- ✅ What a container is
- ✅ What Docker Hub is (pre-built images)
- ✅ How to run a container: `docker run image-name`
- ✅ Understanding Dockerfile basics (from, copy, run, cmd)

### Not needed for this course:
- ❌ How to optimize Docker images
- ❌ How to build multi-stage Dockerfiles
- ❌ Docker networking in detail
- ❌ Docker volumes and persistence

**Why?** This course focuses on Kubernetes. We use pre-built Docker images (like `nginx:1.25`) and don't build our own. You'll use Docker images but won't deep-dive into Docker itself.

---

## Container Registries (Where Images Live)

### Docker Hub (Docker's official)
- Millions of free images
- Official images: python, node, postgres, nginx, etc.
- Example: `docker pull nginx:1.25`

### Private Registries:
- AWS ECR (Elastic Container Registry)
- Google Container Registry
- Azure Container Registry
- Your own private registry

### In Kubernetes Context:
```
Kubernetes pulls images from a registry
┌─────────────────────────┐
│ Docker Hub / ECR / etc. │
└────────────┬────────────┘
             ↓
    Kubernetes pulls it
             ↓
   Runs it in a Pod
```

---

## The Docker Terminology You'll See

| Term | Meaning |
|------|---------|
| **Image** | Blueprint (stored on disk or in registry) |
| **Container** | Running instance of an image |
| **Registry** | Storage for images (Docker Hub, ECR, etc.) |
| **Dockerfile** | Recipe to build a custom image |
| **Docker Compose** | Run multiple containers together (not needed for K8s) |

---

## Real-World Example: Running Nginx

### Without Docker:
```bash
# Install nginx
apt-get install nginx
systemctl start nginx

# Problem: What version? What configuration? How do I move this to another server?
```

### With Docker:
```bash
# Run nginx (pre-built, always the same)
docker run -p 8080:80 nginx:1.25

# It's the same on Mac, Linux, Windows, cloud servers, etc.
```

---

## Why Containers Are Awesome

✅ **Reproducibility:** Same container everywhere  
✅ **Isolation:** One container's crash doesn't affect others  
✅ **Speed:** Start in milliseconds (vs minutes for VMs)  
✅ **Lightweight:** MB instead of GB  
✅ **Scaling:** Easy to run 1 or 1000 copies  

---

## Key Takeaway

**Docker = Packaging your app so it runs the same everywhere**  
**Kubernetes = Running many Docker containers automatically**

Docker solves the "works on my machine" problem. Kubernetes solves the "how do I run thousands of containers" problem.

---

## Next Step

👉 Read [What is a Pod?](./03-what-is-a-pod.md)

(Now that you understand containers, we explain Pods—which are Kubernetes' way of wrapping containers)
