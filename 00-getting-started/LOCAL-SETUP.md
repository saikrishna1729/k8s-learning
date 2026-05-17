# 🖥️ Local Kubernetes Cluster Setup

**Goal:** Install a local Kubernetes cluster so you can run the hands-on modules.

**Time:** 15-20 minutes

---

## Step 1: Choose Your Local Kubernetes Cluster

You need **one** of these three tools. Pick based on your OS and preference:

### Option A: OrbStack (macOS only — Recommended)

**What it is:** Local Kubernetes + Docker combined in one easy tool.

**Pros:**
- Easiest to install and use
- Fastest performance
- Built-in Docker + Kubernetes
- 1 command to start/stop

**Cons:**
- Mac only
- Paid tool (~$100/year)

**Install:**
```bash
# Download from https://orbstack.dev/
# Or via Homebrew:
brew install orbstack

# Start it
orbstack start
```

**Verify:**
```bash
kubectl cluster-info
# Output should show: Kubernetes control plane is running at https://...
```

---

### Option B: Minikube (macOS, Linux, Windows — Free)

**What it is:** Lightweight virtual machine running Kubernetes.

**Pros:**
- Works on all OSes
- Free and open-source
- Stable and widely used
- Good community support

**Cons:**
- Slower than OrbStack
- Uses more CPU/memory
- Requires VirtualBox or Docker Desktop

**Install:**

#### macOS:
```bash
brew install minikube

# Start it (this downloads a VM, takes ~2-3 min first time)
minikube start

# Enable DNS plugin (required for this course)
minikube addons enable dns
```

#### Linux:
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start it
minikube start --driver=docker
```

#### Windows (PowerShell as Admin):
```powershell
choco install minikube
minikube start
```

**Verify:**
```bash
minikube status
# Should show: minikube: Running, kubelet: Running, apiserver: Running
```

---

### Option C: Kind (macOS, Linux, Windows — Free)

**What it is:** Kubernetes in Docker (runs K8s inside containers).

**Pros:**
- Lightweight and fast
- Free and open-source
- Good for CI/CD
- Minimal resource usage

**Cons:**
- Less beginner-friendly
- Networking slightly complex
- Some features not available (e.g., LoadBalancer type needs workaround)

**Install:**

#### macOS:
```bash
brew install kind
```

#### Linux:
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### Windows (PowerShell as Admin):
```powershell
choco install kind
```

**Create a cluster:**
```bash
kind create cluster

# This creates a cluster named "kind-1"
```

**Verify:**
```bash
kubectl cluster-info
# Output should show: Kubernetes control plane is running at https://...
```

---

## Step 2: Install kubectl (All OSes)

`kubectl` is the command-line tool to talk to Kubernetes.

### macOS:
```bash
brew install kubectl

# Verify
kubectl version --client
# Output: Client Version: v1.28.x (or higher)
```

### Linux:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
```

### Windows (PowerShell as Admin):
```powershell
choco install kubernetes-cli

# Verify
kubectl version --client
```

---

## Step 3: Install Helm (Optional but Recommended)

`Helm` is a package manager for Kubernetes. You'll need this in Module 05.

### macOS:
```bash
brew install helm

# Verify
helm version
# Output: version.BuildInfo{Version:"v3.x.x", ...}
```

### Linux:
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

### Windows (PowerShell as Admin):
```powershell
choco install kubernetes-helm

# Verify
helm version
```

---

## Step 4: Verify Everything Works

Run these commands to confirm your setup:

```bash
# Check Kubernetes cluster is running
kubectl cluster-info
# Expected output:
# Kubernetes control plane is running at https://...
# CoreDNS is running at https://...

# Check nodes (should see 1 node for local cluster)
kubectl get nodes
# Expected output:
# NAME          STATUS   ROLES           AGE   VERSION
# minikube      Ready    control-plane   5m    v1.28.0
# (name varies by tool, but should show "Ready")

# Check pods in system namespace
kubectl get pods -n kube-system
# You should see system Pods running (coredns, etcd, etc.)

# Check kubectl version
kubectl version --client
# Should show v1.28+ (or your current version)

# Check Helm version (if installed)
helm version
# Should show v3.x.x
```

---

## Troubleshooting

### Issue: `kubectl: command not found`

**Solution:** kubectl is not in your PATH.

```bash
# Verify it's installed
which kubectl

# If empty, reinstall kubectl
# For macOS: brew install kubectl
# For Linux: curl... (see above)
```

### Issue: `The connection to the server was refused`

**Solution:** Kubernetes cluster isn't running.

```bash
# If using OrbStack:
orbstack start

# If using Minikube:
minikube start

# If using Kind:
kind create cluster
```

### Issue: `cannot create ConfigMap ... (Forbidden)`

**Solution:** Your kubeconfig isn't set up correctly.

```bash
# For Minikube:
minikube update-context

# For Kind:
kubectl config use-context kind-kind

# For OrbStack:
kubectl config use-context orbstack
```

### Issue: Pods are `Pending` or `ImagePullBackOff`

**Solution:** Cluster needs more resources, or your internet connection is slow.

```bash
# Check cluster resources
kubectl top nodes

# If CPU/memory near max, restart cluster:
# OrbStack: orbstack restart
# Minikube: minikube stop && minikube start
# Kind: kind delete cluster && kind create cluster
```

---

## Starting/Stopping Your Cluster

### OrbStack:
```bash
orbstack start    # Start
orbstack stop     # Stop
```

### Minikube:
```bash
minikube start    # Start
minikube stop     # Stop
minikube delete   # Delete (clean slate)
```

### Kind:
```bash
kind create cluster     # Create
kind delete cluster     # Delete
```

---

## What's Running on Your Cluster?

Your local cluster has these system components running in the `kube-system` namespace:

```bash
kubectl get pods -n kube-system

# You should see:
# coredns-*              — DNS server
# etcd-*                 — Database
# kube-apiserver-*       — Kubernetes API
# kube-controller-mgr-*  — Controllers
# kube-scheduler-*       — Pod scheduler
# kube-proxy-*           — Networking
```

These are the Control Plane components explained in [Module 05 — Kubernetes Architecture](./05-kubernetes-architecture.md).

---

## Ready to Learn?

Once you see all the status checks pass, you're ready:

👉 Go back to [LEARNING-PATH.md](../LEARNING-PATH.md) and start with **Module 00: Getting Started**

---

## Quick Reference: Your Setup

Save this for reference:

```bash
# Check cluster status
kubectl cluster-info

# See all Pods (all namespaces)
kubectl get pods -A

# See available nodes
kubectl get nodes

# If something goes wrong, restart:
# OrbStack: orbstack restart
# Minikube: minikube stop && minikube start
# Kind: kind delete cluster && kind create cluster
```

---

## Pro Tips

### Tip 1: Set an Alias
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k=kubectl

# Now you can type: k get pods (instead of kubectl get pods)
```

### Tip 2: Enable Shell Autocompletion
```bash
# For Zsh (macOS default)
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc

# For Bash
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
```

### Tip 3: Save Cluster Context
```bash
# See available clusters
kubectl config get-contexts

# Switch to a specific cluster
kubectl config use-context <name>
```

---

## Still Having Issues?

Check these resources:
- [OrbStack Docs](https://orbstack.dev/docs)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)
- [Kind Docs](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl Docs](https://kubernetes.io/docs/reference/kubectl/)
