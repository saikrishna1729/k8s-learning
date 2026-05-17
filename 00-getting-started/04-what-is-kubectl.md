# 🖥️ What is kubectl?

**Plain English:** kubectl is the command-line tool you use to tell Kubernetes what to do. It's like `git` for Kubernetes.

---

## What is kubectl?

### The Comparison:

```
Git (for code version control):
  git status          # See git status
  git add file.txt    # Add file
  git commit -m "..."  # Commit changes
  git push origin main # Push to remote

kubectl (for Kubernetes management):
  kubectl get pods          # See running Pods
  kubectl apply -f app.yaml # Deploy app
  kubectl delete pod my-pod # Delete Pod
  kubectl logs my-pod       # See logs
```

### How kubectl Works:

```
Your Computer
  ↓
You run: kubectl apply -f deployment.yaml
  ↓
kubectl converts YAML to JSON
  ↓
Sends request to Kubernetes API Server
  ↓
API Server processes request
  ↓
Kubernetes takes action
  ↓
You see result: "deployment.apps/my-app created"
```

---

## Installing kubectl

### On Mac:
```bash
# Using Homebrew
brew install kubectl

# Verify installation
kubectl version --client
```

### On Linux:
```bash
# Using curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### On Windows:
```bash
# Using chocolatey
choco install kubernetes-cli

# Or download directly from:
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

---

## kubectl Syntax

### Basic Pattern:

```
kubectl [COMMAND] [TYPE] [NAME] [FLAGS]

COMMAND:  get, apply, delete, describe, logs, etc.
TYPE:     pods, deployments, services, nodes, etc.
NAME:     specific resource name (optional)
FLAGS:    --namespace, -o yaml, -w for watch, etc.
```

### Examples:

```bash
# Get all Pods
kubectl get pods

# Get specific Pod
kubectl get pod my-pod

# Get Pod with details (wide output)
kubectl get pods -o wide

# Get Pod in YAML format
kubectl get pod my-pod -o yaml

# Watch Pods in real-time (updates as they change)
kubectl get pods -w

# Get Pods in all namespaces
kubectl get pods -A  # or --all-namespaces
```

---

## Core kubectl Commands (What You'll Use Most)

### 1. Get Resources
```bash
# List all Pods in current namespace
kubectl get pods

# List all Deployments
kubectl get deployments

# List all Services
kubectl get services

# List all resources
kubectl get all

# Get in wide format (more columns)
kubectl get pods -o wide

# Get as YAML
kubectl get pod my-pod -o yaml

# Get as JSON
kubectl get pod my-pod -o json

# Watch for changes (refreshes every second)
kubectl get pods -w
```

### 2. Apply (Create or Update)
```bash
# Apply a single file
kubectl apply -f deployment.yaml

# Apply a directory (all YAML files in it)
kubectl apply -f ./k8s/

# Apply from URL
kubectl apply -f https://example.com/manifest.yaml

# Dry run (show what would happen, don't actually do it)
kubectl apply -f deployment.yaml --dry-run=client

# See what changed
kubectl apply -f deployment.yaml -v=2
```

### 3. Delete Resources
```bash
# Delete by name
kubectl delete pod my-pod

# Delete all Pods with label
kubectl delete pods -l app=my-app

# Delete all Pods in namespace
kubectl delete pods --all

# Delete deployment (also deletes its Pods)
kubectl delete deployment my-app

# Delete multiple resources
kubectl delete pods,services,deployments --all
```

### 4. Describe (Get Detailed Info)
```bash
# See all details about a Pod
kubectl describe pod my-pod

# See deployment details
kubectl describe deployment my-app

# See node details
kubectl describe node node-1

# Shows events (what happened recently)
```

### 5. Logs (See Container Output)
```bash
# Show logs from a Pod
kubectl logs my-pod

# Show logs from a specific container (if Pod has multiple)
kubectl logs my-pod -c container-name

# Follow logs (like tail -f)
kubectl logs my-pod -f

# Show last 50 lines
kubectl logs my-pod --tail=50

# Show logs from the last 1 hour
kubectl logs my-pod --since=1h

# Show logs with timestamps
kubectl logs my-pod --timestamps=true
```

### 6. Exec (Run Commands Inside Container)
```bash
# Run a command in a Pod
kubectl exec my-pod -- ls -la

# Get a shell (interactive)
kubectl exec -it my-pod -- /bin/bash

# Run command in specific container
kubectl exec my-pod -c container-name -- whoami

# Difference from SSH:
#   SSH: logs into a server
#   kubectl exec: runs command inside a container
```

### 7. Port-Forward (Access Pod Locally)
```bash
# Forward local port 8080 to Pod port 80
kubectl port-forward pod/my-pod 8080:80

# Can then access: curl http://localhost:8080

# Forward to service
kubectl port-forward service/my-service 8080:80

# Forward to deployment
kubectl port-forward deployment/my-app 8080:80
```

### 8. Scale (Change Replica Count)
```bash
# Scale deployment to 5 replicas
kubectl scale deployment my-app --replicas 5

# Scale down to 1
kubectl scale deployment my-app --replicas 1

# View replica status
kubectl get deployment my-app
```

### 9. Rollout (Update Deployments)
```bash
# Check rollout status
kubectl rollout status deployment/my-app

# See rollout history
kubectl rollout history deployment/my-app

# Rollback to previous version
kubectl rollout undo deployment/my-app

# Rollback to specific revision
kubectl rollout undo deployment/my-app --to-revision=2
```

---

## kubectl Context & Kubeconfig

### What is kubeconfig?

Kubeconfig is a file that stores cluster connection details:

```yaml
clusters:
- name: my-cluster
  cluster:
    server: https://api.my-cluster.com
    certificate-authority: ca.crt
users:
- name: my-user
  user:
    client-certificate: client.crt
    client-key: client.key
contexts:
- name: my-context
  context:
    cluster: my-cluster
    user: my-user
```

### Common kubeconfig Commands:

```bash
# Show current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch to a different context
kubectl config use-context my-cluster

# Show kubeconfig file location
kubectl config view

# Show full kubeconfig
kubectl config view --raw

# Set a new context
kubectl config set-context my-context --cluster=my-cluster --user=my-user
```

---

## Namespaces (Organizing Clusters)

### What is a Namespace?

Namespace = virtual cluster inside one cluster.

```
One Kubernetes Cluster
├─ Namespace: default
│  ├─ Pod: app-1
│  ├─ Pod: app-2
│  ├─ Service: app-service
├─ Namespace: production
│  ├─ Pod: real-app-1
│  ├─ Pod: real-app-2
├─ Namespace: testing
│  ├─ Pod: test-app-1
```

### Namespace Commands:

```bash
# List namespaces
kubectl get namespaces

# Get Pods in a specific namespace
kubectl get pods -n kube-system

# Get Pods in all namespaces
kubectl get pods -A

# Create a namespace
kubectl create namespace my-namespace

# Deploy to a specific namespace
kubectl apply -f app.yaml -n my-namespace

# Switch default namespace (optional, usually just use -n flag)
kubectl config set-context --current --namespace=my-namespace
```

---

## Real-World kubectl Workflow

### Scenario: Deploy an app

```bash
# Step 1: Create deployment YAML file
cat > deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# Step 2: Deploy
kubectl apply -f deployment.yaml

# Step 3: Check deployment status
kubectl get deployments
kubectl describe deployment my-app

# Step 4: Check Pods
kubectl get pods
kubectl get pods -w  # Watch for Ready status

# Step 5: Check logs
kubectl logs deployment/my-app

# Step 6: Access the app
kubectl port-forward deployment/my-app 8080:80
# Now access: curl http://localhost:8080

# Step 7: Update the app (change image)
kubectl set image deployment/my-app app=nginx:1.26 --record

# Step 8: Check rollout status
kubectl rollout status deployment/my-app

# Step 9: If something went wrong, rollback
kubectl rollout undo deployment/my-app

# Step 10: Delete everything
kubectl delete deployment my-app
```

---

## kubectl Tips & Tricks

### Alias for Faster Typing:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k=kubectl

# Now you can type:
k get pods          # Instead of: kubectl get pods
k apply -f app.yaml # Instead of: kubectl apply -f app.yaml
k logs my-pod       # Instead of: kubectl logs my-pod
```

### Output Formats:
```bash
# Human-readable (default)
kubectl get pods

# Wide (more columns)
kubectl get pods -o wide

# YAML (useful for debugging)
kubectl get pod my-pod -o yaml

# JSON (for automation/scripting)
kubectl get pods -o json

# Just the names (useful in scripts)
kubectl get pods -o name
```

### Useful Flags:
```bash
# All namespaces
-A or --all-namespaces

# Specific namespace
-n or --namespace

# Label selector
-l or --selector (e.g., -l app=my-app)

# Watch for changes
-w or --watch

# Sort by a field
--sort-by=.metadata.creationTimestamp

# Show in wide format (more columns)
-o wide
```

### Debugging:
```bash
# Increase verbosity (show more details)
kubectl apply -f app.yaml -v=4

# Dry run (show what would happen)
kubectl apply -f app.yaml --dry-run=client

# See API requests being made
kubectl apply -f app.yaml -v=9
```

---

## kubectl vs API Server

### kubectl is the client:
```
You ←→ kubectl ←→ API Server ←→ Kubernetes
```

### What actually happens:
```bash
# You type:
kubectl apply -f deployment.yaml

# kubectl does:
1. Reads deployment.yaml
2. Validates YAML syntax
3. Converts to JSON
4. Sends REST request to API Server
5. API Server processes it
6. API Server updates etcd database
7. Controllers see the change and take action
8. Kubernetes creates the Deployment and Pods
9. kubectl shows you: "deployment.apps/my-app created"
```

---

## Common kubectl Mistakes

### ❌ Mistake 1: Forgetting namespace flag
```bash
# Wrong: Deploys to default namespace
kubectl apply -f app.yaml

# Right: Deploys to production namespace
kubectl apply -f app.yaml -n production
```

### ❌ Mistake 2: Not using -A when checking all namespaces
```bash
# Wrong: Only shows Pods in default namespace
kubectl get pods

# Right: Shows Pods in all namespaces
kubectl get pods -A
```

### ❌ Mistake 3: Deleting without confirmation
```bash
# Wrong: Deletes immediately
kubectl delete deployment my-app

# Better: First check what would be deleted
kubectl get deployment my-app
```

### ❌ Mistake 4: Modifying Pod directly instead of Deployment
```bash
# Wrong: Modifying Pod directly (gets recreated anyway)
kubectl exec my-pod -- apt-get install curl

# Right: Update Deployment YAML and reapply
kubectl apply -f deployment.yaml
```

---

## Key Takeaway

**kubectl = your tool to manage Kubernetes**

You don't need to memorize all commands. Common ones:
- `kubectl get` — see what's running
- `kubectl apply` — deploy changes
- `kubectl delete` — remove resources
- `kubectl logs` — see what happened
- `kubectl describe` — get details
- `kubectl exec` — run commands in containers

Everything follows the pattern: `kubectl [action] [resource] [name]`

---

## Next Step

👉 Read [Kubernetes Architecture](./05-kubernetes-architecture.md)

(Now that you know how to talk to Kubernetes, understand what's actually happening behind the scenes)
