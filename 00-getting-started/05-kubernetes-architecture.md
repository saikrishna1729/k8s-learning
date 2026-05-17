# 🏗️ Kubernetes Architecture

**Plain English:** Kubernetes has two parts: Control Plane (the brain) and Worker Nodes (the muscles). Control Plane makes decisions, Worker Nodes run your apps.

---

## The Two-Part System

### Analogy: Restaurant Management

```
CONTROL PLANE (The Manager):
- Takes orders from customers
- Decides which chef should cook what
- Monitors the kitchen
- Makes sure everything runs smoothly
- Doesn't cook the food

WORKER NODES (The Chefs):
- Actually cook the food
- Follow the manager's instructions
- Report problems back to manager
- Do the actual work

You:
- Tell the manager what you want (kubectl)
- Manager handles the rest
```

---

## Kubernetes Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTROL PLANE (Master)                       │
│                    (Makes Decisions)                             │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │  API Server  │  │  Scheduler   │  │ Controller Manager  │   │
│  │              │  │              │  │                     │   │
│  │ Receives all │  │ Decides which│  │ Makes sure desired  │   │
│  │ requests     │  │ Pod goes on  │  │ state matches actual│   │
│  │ from kubectl │  │ which Node   │  │ state               │   │
│  └──────────────┘  └──────────────┘  └─────────────────────┘   │
│         ↑                                                         │
│         │                                                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              etcd (Database)                             │   │
│  │  Stores all cluster state                               │   │
│  │  (what Pods exist, what Deployments exist, etc.)       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
  ↓       ↓         ↓
  │       │         │ Control plane talks to worker nodes
  │       │         │
  ↓       ↓         ↓

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  WORKER NODE 1   │  │  WORKER NODE 2   │  │  WORKER NODE 3   │
│  (Does the Work) │  │  (Does the Work) │  │  (Does the Work) │
│                  │  │                  │  │                  │
│  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────────┐  │
│  │  kubelet   │  │  │  │  kubelet   │  │  │  │  kubelet   │  │
│  │ (Agent)    │  │  │  │ (Agent)    │  │  │  │ (Agent)    │  │
│  └────────────┘  │  │  └────────────┘  │  │  └────────────┘  │
│        ↓         │  │        ↓         │  │        ↓         │
│  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────────┐  │
│  │ kube-proxy │  │  │  │ kube-proxy │  │  │  │ kube-proxy │  │
│  │(Networking)│  │  │  │(Networking)│  │  │  │(Networking)│  │
│  └────────────┘  │  │  └────────────┘  │  │  └────────────┘  │
│        ↓         │  │        ↓         │  │        ↓         │
│  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────────┐  │
│  │ Container  │  │  │  │ Container  │  │  │  │ Container  │  │
│  │  Runtime   │  │  │  │  Runtime   │  │  │  │  Runtime   │  │
│  │ (Docker)   │  │  │  │ (Docker)   │  │  │  │ (Docker)   │  │
│  └────────────┘  │  │  └────────────┘  │  │  └────────────┘  │
│        ↓         │  │        ↓         │  │        ↓         │
│  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────────┐  │
│  │    Pods    │  │  │  │    Pods    │  │  │  │    Pods    │  │
│  │  (Your     │  │  │  │  (Your     │  │  │  │  (Your     │  │
│  │   Apps)    │  │  │  │   Apps)    │  │  │  │   Apps)    │  │
│  └────────────┘  │  │  └────────────┘  │  │  └────────────┘  │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

---

## Control Plane Components

### 1. API Server
**Job:** Receives all requests and updates cluster state

```
What it does:
- Listens for kubectl commands
- Validates requests (is the YAML valid?)
- Updates etcd database (the source of truth)
- Notifies other components about changes
- Authenticates and authorizes access (who is allowed to do what?)

Example:
You: kubectl apply -f deployment.yaml
  ↓
API Server: "Got it. Deployment request received."
  ↓
API Server: "Checking YAML syntax... Valid!"
  ↓
API Server: "Checking permissions... User allowed to create Deployments."
  ↓
API Server: "Saving to etcd database"
  ↓
API Server: "Notifying Scheduler about the new Deployment"
```

### 2. Scheduler
**Job:** Decides which Pod goes on which Node

```
What it does:
- Watches for new Pods that need a Node
- Evaluates all nodes (CPU available? Memory available? Node labels match?)
- Picks the best node (the one with most available resources)
- Assigns the Pod to that node

Example:
Deployment creates 3 new Pods
  ↓
Scheduler sees 3 unscheduled Pods
  ↓
Scheduler evaluates nodes:
  - Node 1: 20% CPU, 50% memory → good fit
  - Node 2: 80% CPU, 10% memory → not good
  - Node 3: 30% CPU, 40% memory → good fit
  ↓
Scheduler assigns:
  - Pod 1 → Node 1
  - Pod 2 → Node 1
  - Pod 3 → Node 3

Then kubelet on each node sees: "I have new Pods to run"
```

### 3. Controller Manager
**Job:** Ensures desired state matches actual state

```
What it does:
- Runs many "controllers" (small programs)
- Each controller watches for drift between what you want and what exists
- Fixes drift automatically

Controllers include:
- Deployment Controller: "You want 3 Pods, but only 2 are running. Creating 1 more."
- ReplicaSet Controller: "If a Pod crashes, create a new one."
- Service Controller: "If a Service is added, configure load balancing."
- Node Controller: "If a Node is unreachable, mark Pods as failed."

Example:
You create a Deployment saying "I want 3 nginx Pods"
  ↓
Deployment Controller creates a ReplicaSet (manages the Pods)
  ↓
ReplicaSet Controller: "3 Pods requested, 3 Pods running. ✓ Good."
  ↓
One Pod crashes
  ↓
ReplicaSet Controller: "3 Pods requested, but only 2 running. Creating new Pod."
  ↓
ReplicaSet Controller: "3 Pods requested, 3 Pods running. ✓ Good."
```

### 4. etcd (Database)
**Job:** Stores the state of everything

```
What it does:
- Key-value database (stores data as key: value pairs)
- Single source of truth for entire cluster
- Stores:
  - Pods (what Pods exist, what state they're in)
  - Deployments (what Deployments exist)
  - Services (what Services exist)
  - ConfigMaps, Secrets, PersistentVolumes, etc.
  - User permissions (RBAC)

Example:
/pods/default/nginx-pod-1 → {"status": "Running", "node": "node-1"}
/deployments/default/my-app → {"replicas": 3, "image": "nginx:1.25"}
/services/default/my-service → {"type": "ClusterIP", "port": 80}

When API Server gets a request:
1. Updates etcd database
2. Notifies controllers: "Something changed!"
3. Controllers read the new state from etcd
4. Controllers take action
```

---

## Worker Node Components

### 1. kubelet (Agent)
**Job:** Manages Pods on this Node

```
What it does:
- Listens to API Server: "This node should have Pod X"
- Talks to container runtime: "Please start Pod X"
- Monitors the Pod (is it healthy? is it using too much CPU?)
- Reports status back to API Server: "Pod X is Running"
- If Pod crashes, restarts it automatically (unless you told it not to)

Example:
API Server: "Node 1, run Pod: nginx-pod-1"
  ↓
kubelet on Node 1: "Received. Starting container..."
  ↓
kubelet: "Container started, checking if it's healthy..."
  ↓
kubelet: "Health check failed. Restarting..."
  ↓
kubelet: "Container running again. Reporting to API Server..."
  ↓
kubelet: "Pod is Running and healthy. ✓"
```

### 2. kube-proxy (Networking)
**Job:** Routes network traffic to Pods

```
What it does:
- Updates node firewall rules
- Routes traffic from Service IP to Pod IPs
- Load-balances traffic across multiple Pods

Example:
User makes request to Service IP: 10.0.0.1
  ↓
kube-proxy: "Service 10.0.0.1 should route to Pods"
  ↓
kube-proxy checks Service: "This Service has 3 Pods:
  - Pod 1: 10.1.0.1
  - Pod 2: 10.1.0.2
  - Pod 3: 10.1.0.3"
  ↓
kube-proxy: "Round-robin load balancing"
  - Request 1 → Pod 1
  - Request 2 → Pod 2
  - Request 3 → Pod 3
  - Request 4 → Pod 1 (cycle repeats)
```

### 3. Container Runtime
**Job:** Pulls and runs containers

```
What it does:
- Pulls container images from registries (Docker Hub, ECR, etc.)
- Runs containers inside the Pod
- Monitors container status
- Cleans up stopped containers

The container runtime is usually Docker, but can be:
- Docker (most common)
- containerd (modern, faster)
- CRI-O (alternative)

kubelet talks to container runtime via an API, not directly.
```

---

## How Everything Works Together: Deployment Flow

### Scenario: You deploy an app

```
Step 1: You run kubectl
┌──────────────────────────────────────────────────────────┐
│ You type:                                                │
│ kubectl apply -f deployment.yaml                         │
│                                                          │
│ deployment.yaml contains:                               │
│   kind: Deployment                                       │
│   spec:                                                 │
│     replicas: 3                                         │
│     template:                                            │
│       image: nginx:1.25                                 │
└──────────────────────────────────────────────────────────┘
                           ↓

Step 2: API Server receives request
┌──────────────────────────────────────────────────────────┐
│ API Server:                                              │
│ 1. Validates YAML syntax ✓                              │
│ 2. Checks permissions (can this user create?) ✓         │
│ 3. Saves Deployment to etcd: "Want 3 nginx Pods"        │
│ 4. Notifies controllers: "New Deployment created!"      │
└──────────────────────────────────────────────────────────┘
                           ↓

Step 3: Deployment Controller
┌──────────────────────────────────────────────────────────┐
│ Deployment Controller sees new Deployment                │
│ Creates a ReplicaSet (manages the Pods)                 │
│ Saves ReplicaSet to etcd: "Need 3 Pods"                │
│ Notifies ReplicaSet Controller: "New ReplicaSet!"       │
└──────────────────────────────────────────────────────────┘
                           ↓

Step 4: ReplicaSet Controller
┌──────────────────────────────────────────────────────────┐
│ ReplicaSet Controller sees new ReplicaSet               │
│ Creates 3 Pod objects in etcd:                          │
│   - nginx-pod-1                                          │
│   - nginx-pod-2                                          │
│   - nginx-pod-3                                          │
│ API Server notifies Scheduler: "3 Pods need nodes!"     │
└──────────────────────────────────────────────────────────┘
                           ↓

Step 5: Scheduler
┌──────────────────────────────────────────────────────────┐
│ Scheduler sees 3 unscheduled Pods                       │
│ Evaluates all nodes:                                     │
│   - Node 1: 2 CPUs free, 4GB RAM free ← best fit       │
│   - Node 2: 1 CPU free, 2GB RAM free                    │
│   - Node 3: 3 CPUs free, 8GB RAM free ← also good      │
│                                                          │
│ Assigns Pods:                                            │
│   - nginx-pod-1 → Node 1                               │
│   - nginx-pod-2 → Node 1                               │
│   - nginx-pod-3 → Node 3                               │
│ Saves assignments to etcd                               │
└──────────────────────────────────────────────────────────┘
                           ↓

Step 6: kubelet on each Node
┌──────────────────────────────────────────────────────────┐
│ kubelet on Node 1:                                       │
│ 1. Watches etcd: "I'm assigned 2 Pods!"                 │
│ 2. Tells container runtime: "Start nginx:1.25"          │
│ 3. Container runtime pulls image from Docker Hub        │
│ 4. Container starts                                      │
│ 5. kubelet checks health: "Is container running?"       │
│ 6. Reports to API Server: "Pods are Running ✓"          │
│                                                          │
│ kubelet on Node 3:                                       │
│ 1. Watches etcd: "I'm assigned 1 Pod!"                  │
│ 2. Tells container runtime: "Start nginx:1.25"          │
│ 3. Container starts                                      │
│ 4. Reports to API Server: "Pod is Running ✓"            │
└──────────────────────────────────────────────────────────┘
                           ↓

Step 7: Result
┌──────────────────────────────────────────────────────────┐
│ 3 nginx containers running:                             │
│   - Node 1: nginx-pod-1 ✓ running, nginx-pod-2 ✓       │
│   - Node 3: nginx-pod-3 ✓ running                       │
│                                                          │
│ You can access them via Service (load balancer)        │
│ If one crashes, Controller Manager notices             │
│ ReplicaSet creates a replacement Pod                   │
└──────────────────────────────────────────────────────────┘
```

---

## Cluster: Control Plane + Worker Nodes

### Definition:

**Cluster** = One Control Plane + Multiple Worker Nodes

```
Cluster Name: "production-cluster"

┌─────────────────────────────────────────────────────────┐
│          Control Plane (1 or HA-setup with 3)          │
│  (In managed services like EKS, AWS runs this)         │
└─────────────────────────────────────────────────────────┘

Connected to:

┌─────────────────────────────────────────────────────────┐
│              Worker Nodes (1 or more)                  │
│  (You create and manage these, or AWS manages them)    │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │   Node 1    │  │   Node 2    │  │   Node 3    │   │
│  │   (worker)  │  │   (worker)  │  │   (worker)  │   │
│  └─────────────┘  └─────────────┘  └─────────────┘   │
│                                                         │
│  Pods run here                                         │
│  Control Plane never runs Pods (usually)              │
└─────────────────────────────────────────────────────────┘
```

---

## Control Plane High Availability (HA)

### Single Control Plane (Development):
```
Problem: If Control Plane goes down, can't create/delete Pods
Existing Pods keep running (kubelet is independent)
But you can't change anything until Control Plane recovers

┌──────────────────────────┐
│   Control Plane          │
│   (Single instance)      │
└──────────────────────────┘
         ↓
    CRASH!
     ✗ Bad
```

### Multiple Control Planes (Production):
```
Benefit: If one Control Plane fails, others take over

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Control Plane 1  │  │ Control Plane 2  │  │ Control Plane 3  │
│ (API Server)     │  │ (API Server)     │  │ (API Server)     │
│ (Scheduler)      │  │ (Scheduler)      │  │ (Scheduler)      │
│ (Controller Mgr) │  │ (Controller Mgr) │  │ (Controller Mgr) │
└──────────────────┘  └──────────────────┘  └──────────────────┘
    ↓                      ↓                      ↓
All write to same etcd database (replicated across 3)

If one fails:
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Control Plane 1  │  │ Control Plane 2  │  │ Control Plane 3  │
│     ✗ CRASH      │  │    ✓ Running     │  │    ✓ Running     │
└──────────────────┘  └──────────────────┘  └──────────────────┘

Cluster still works (2 out of 3 are up)
```

---

## Key Takeaway

**Kubernetes has two parts:**

1. **Control Plane (The Brain):** Makes decisions
   - API Server: takes your requests
   - Scheduler: assigns Pods to nodes
   - Controller Manager: ensures desired state
   - etcd: database of everything

2. **Worker Nodes (The Muscles):** Runs your apps
   - kubelet: manages Pods
   - kube-proxy: handles networking
   - Container Runtime: runs containers

**What happens when you deploy:**
1. You run kubectl
2. API Server stores in etcd
3. Scheduler assigns to nodes
4. Controllers ensure state
5. kubelets on nodes run containers
6. Your app is now running

---

## Next Step

👉 Read [YAML Explained](./06-yaml-explained.md)

(Now that you understand the architecture, learn the YAML syntax you use to tell Kubernetes what to do)
