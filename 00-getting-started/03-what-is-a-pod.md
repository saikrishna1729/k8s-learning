# 🐳 What is a Pod?

**Plain English:** A Pod is Kubernetes' way of wrapping a container. It's the smallest unit of work in Kubernetes.

---

## The Relationship: Container vs Pod

### Docker Container (What you learned in Module 02):
- Docker's unit of packaging
- One app in one container
- Run with: `docker run nginx:1.25`

### Kubernetes Pod (Kubernetes' unit of work):
- Wrapper around a container (or containers)
- One or more containers inside
- Run with: `kubectl apply -f pod.yaml`

**Key insight:** If Docker containers are "apps," then Pods are "Kubernetes apps."

---

## Why Not Just Use Containers?

Good question! Here's why Kubernetes wraps containers in Pods:

### Without Pods (just raw containers):
```
Kubernetes says: "Run this container on node 5"
Container runs on node 5
Node 5 crashes
Container is gone—Kubernetes can't restart it
Container has no DNS name
Container can't easily talk to other containers
```

### With Pods (Kubernetes wrapper):
```
Kubernetes says: "Run this Pod on node 5"
Pod wraps the container
Node 5 crashes
Kubernetes automatically restarts the Pod on another node
Pod has a DNS name (my-pod-1.default.svc.cluster.local)
Containers in same Pod share network
Easy to scale (replicate the Pod)
```

**Translation:** Pods give Kubernetes a standard way to manage, restart, scale, and network applications.

---

## Pod Structure

### Simple Pod (Most Common):

```
┌─────────────────────────────┐
│         Pod                 │
│  (Kubernetes wrapper)       │
│                             │
│  ┌───────────────────────┐  │
│  │  Container 1          │  │
│  │  (nginx)              │  │
│  │  Port 80              │  │
│  └───────────────────────┘  │
│                             │
│  Shared network namespace   │
│  - Same IP address          │
│  - Port mapping (80→8080)   │
│  - Shared storage mounts    │
└─────────────────────────────┘
```

### Multi-Container Pod (Rare but Important):

```
┌─────────────────────────────┐
│         Pod                 │
│  (Shared network & storage) │
│                             │
│  ┌──────────────┐           │
│  │ Container 1  │  (app)    │
│  │ Port 3000    │           │
│  └──────────────┘           │
│                             │
│  ┌──────────────┐           │
│  │ Container 2  │  (sidecar)│
│  │ Port 9090    │           │
│  └──────────────┘           │
│                             │
│  Both see each other via    │
│  localhost + port           │
└─────────────────────────────┘
```

---

## Key Pod Properties

| Property | Explanation |
|----------|-------------|
| **IP Address** | All containers in Pod share the same IP (127.0.0.1 to reach sibling container) |
| **Network Namespace** | Containers in Pod see each other as localhost |
| **Storage** | Can mount shared volumes (container A writes, container B reads) |
| **Lifecycle** | All containers start/stop together (if one dies, Pod is considered failed) |
| **Scheduling** | Pod placed on one node (all containers run on same node) |
| **Lifecycle Hooks** | Pre-start, post-stop handlers for graceful startup/shutdown |

---

## Single vs Multi-Container Pods

### ✅ Single Container Pod (99% of cases):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
```

**When to use:** Almost always. One app = one container = one Pod.

### ⚠️ Multi-Container Pod (1% of cases):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logging-sidecar
spec:
  containers:
  - name: app
    image: my-app:1.0
    ports:
    - containerPort: 3000
    
  - name: logging-agent
    image: fluent-bit:2.0
    # This container ships logs from app container
```

**When to use:** Only when containers are tightly coupled:
- Log shipper (app writes logs, sidecar ships them)
- Monitoring agent (app runs, agent monitors it)
- Reverse proxy sidecar (app on port 3000, sidecar exposes port 8080)

**Rule of thumb:** If you can run them separately, they should be in separate Pods.

---

## Pod Lifecycle

### Pod Creation:
```
1. You write Pod YAML
2. kubectl sends to Kubernetes API
3. Kubernetes schedules Pod on a node
4. kubelet (agent on node) pulls container image
5. Container starts inside Pod
6. Pod becomes "Running"
```

### Pod Health Checking:
```
Readiness Probe: "Is the container ready to receive traffic?"
  ↓ (checks every 10 seconds)
  Passes → Pod marked "Ready" → Service routes traffic here
  Fails → Pod marked "Not Ready" → Service stops routing here

Liveness Probe: "Is the container still alive?"
  ↓ (checks every 10 seconds)
  Fails → Container restarts
  Still fails → Pod marked "Failed"
```

### Pod Termination:
```
1. You run: kubectl delete pod my-pod
2. Kubernetes sends SIGTERM to container (30 seconds to gracefully shutdown)
3. Container handles SIGTERM, closes connections, cleans up
4. After 30 seconds (or sooner if container exits), SIGKILL sent
5. Pod is gone
```

---

## Pod Networking (Why Containers Share IP)

### Inside a Pod:
```
Container A                    Container B
Port 3000 (app)               Port 9090 (monitoring)
↓                              ↓
Both have same IP: 10.0.1.5    Both have same IP: 10.0.1.5

Container A can call Container B via:
  curl http://localhost:9090

Container B can call Container A via:
  curl http://localhost:3000
```

### Why share IP?
- **Simplicity:** Both containers see each other as localhost
- **Atomic unit:** Pod scales as one, not individual containers
- **Security:** OS-level isolation (network namespace still applies)
- **Storage:** Can mount same volume (app writes, sidecar reads)

---

## Pod vs Deployment

### Pod (What you see):
- One instance of your app
- No restart if it crashes
- No rolling updates
- Manual management

### Deployment (What you use in practice):
- Creates multiple Pods (replicas)
- Auto-restarts if Pod crashes
- Handles rolling updates
- Scales easily
- Manages Pods for you

**Simple rule:** You'll write Pod YAML in tutorials to understand how Kubernetes works. But in production, you'll use Deployments (which manage Pods for you).

---

## Pod Labels and Selectors

Pods need labels so Kubernetes can organize them:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app        # Label 1
    version: v1        # Label 2
    env: production    # Label 3
```

Why labels?
- **Services find Pods:** Service selector `app: my-app` finds all Pods with that label
- **Organization:** Group related Pods
- **Selection:** `kubectl get pods -l app=my-app` finds all Pods with label `app: my-app`

---

## Real-World Pod Example: Nginx

### Simple Nginx Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
    resources:
      requests:
        cpu: 100m        # 0.1 CPU cores
        memory: 128Mi    # 128 MB RAM
      limits:
        cpu: 200m        # Max 0.2 CPU cores
        memory: 256Mi    # Max 256 MB RAM
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
```

**What this does:**
- Runs nginx container
- Requests 100m CPU, 128 MB RAM (what it normally needs)
- Limits to 200m CPU, 256 MB RAM (max allowed)
- Checks every 10 seconds: is nginx responding to HTTP requests?
- If not responding, restarts the container

---

## Pod vs Docker Container vs Deployment (Visual)

```
DOCKER CONTAINER (Docker's unit):
┌──────────────────────────┐
│ Container (isolated app) │
│ - No automatic restart   │
│ - Manual management      │
│ - One IP per container   │
└──────────────────────────┘

KUBERNETES POD (Kubernetes' unit):
┌──────────────────────────┐
│ Pod (Kubernetes wrapper) │
│ ├─ Container 1           │
│ ├─ Container 2 (optional)│
│ - Shared IP              │
│ - Restart if crashes     │
│ - Manual scaling         │
└──────────────────────────┘

KUBERNETES DEPLOYMENT (Kubernetes' best practice):
┌──────────────────────────┐
│ Deployment               │
│ (manages Pods for you)   │
├────────────────────────┐ │
│ Pod replica 1          │ │
│ ├─ nginx container     │ │
└────────────────────────┘ │
├────────────────────────┐ │
│ Pod replica 2          │ │
│ ├─ nginx container     │ │
└────────────────────────┘ │
├────────────────────────┐ │
│ Pod replica 3          │ │
│ ├─ nginx container     │ │
└────────────────────────┘ │
- Auto-restart Pods        │
- Rolling updates          │
- Auto-scaling             │
- Zero-downtime deploy     │
└──────────────────────────┘
```

---

## Key Takeaway

**Pod = Kubernetes wrapper around container(s)**

- Usually: 1 container per Pod
- Sometimes: 2-3 containers per Pod (tightly coupled)
- Never: Many unrelated containers in one Pod

In practice:
- You'll write Pod YAML to learn
- You'll use Deployment YAML to deploy (Deployment manages Pods)
- You'll use Service to expose Pods to traffic

---

## Next Step

👉 Read [What is kubectl?](./04-what-is-kubectl.md)

(Now that you understand Pods, learn the tool you use to create and manage them)
