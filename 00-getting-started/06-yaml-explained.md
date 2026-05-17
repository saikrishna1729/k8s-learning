# 📝 YAML Explained

**Plain English:** YAML is a file format for configuration. Kubernetes uses YAML to describe what you want to deploy.

---

## What is YAML?

### YAML Stands For:
**YAML Ain't Markup Language** (yes, it's a recursive acronym!)

### YAML is:
- Human-readable format for data (easier to read than JSON)
- Uses indentation to show structure (like Python)
- Common in configuration files

### Comparison: JSON vs YAML

#### JSON (Machine-friendly):
```json
{
  "name": "nginx",
  "version": 1.25,
  "ports": [80, 443],
  "enabled": true
}
```

#### YAML (Human-friendly):
```yaml
name: nginx
version: 1.25
ports:
  - 80
  - 443
enabled: true
```

**Same data, different format. Kubernetes prefers YAML.**

---

## YAML Syntax Basics

### 1. Key-Value Pairs
```yaml
# Format: key: value
name: nginx
image: nginx:1.25
port: 80
```

### 2. Nested Data (Indentation)
```yaml
# Use indentation (spaces, not tabs!) to nest
app:
  name: my-app
  version: 1.0
  database:
    host: db.example.com
    port: 5432

# Same data in JSON would be:
# {"app": {"name": "my-app", "version": 1.0, "database": {"host": "db.example.com", "port": 5432}}}
```

### 3. Lists (Dashes)
```yaml
# Lists use dashes
containers:
  - name: app
    image: nginx:1.25
  - name: database
    image: postgres:15

# In JSON:
# {"containers": [{"name": "app", "image": "nginx:1.25"}, {"name": "database", "image": "postgres:15"}]}
```

### 4. Data Types
```yaml
# Strings (quotes optional for simple values)
name: my-app                  # String
description: "Hello world"    # String with quotes

# Numbers
port: 8080                    # Integer
memory: 256Mi                 # String (Kubernetes uses strings for quantities)
replicas: 3                   # Integer

# Booleans
enabled: true                 # Boolean
disabled: false               # Boolean

# Null
value: null                   # Null/empty

# Lists
ports:
  - 80
  - 443
  - 8080

# Nested objects
config:
  database:
    host: db.local
    port: 5432
```

### 5. Comments
```yaml
# This is a comment
key: value  # Inline comment
# Comments start with #
```

---

## Kubernetes YAML Structure

Every Kubernetes YAML has 4 main sections:

```yaml
apiVersion: v1              # What version of Kubernetes API?
kind: Pod                   # What type of object? (Pod, Deployment, Service, etc.)
metadata:                   # Data ABOUT the object (name, labels, namespace)
  name: my-pod
  labels:
    app: my-app
spec:                       # The actual specification (what you want)
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
```

### 1. apiVersion
**What it is:** The Kubernetes API version

```yaml
apiVersion: v1              # Core APIs (Pods, Services, etc.)
# OR
apiVersion: apps/v1         # App APIs (Deployments, StatefulSets, etc.)
# OR
apiVersion: networking.k8s.io/v1  # Networking APIs (Ingress, NetworkPolicy, etc.)
```

**Why it matters:** Different API versions support different features. Usually you don't need to think about it.

```bash
# See what API versions your cluster supports
kubectl api-versions

# Output might show:
# v1
# apps/v1
# batch/v1
# networking.k8s.io/v1
# storage.k8s.io/v1
# etc.
```

### 2. kind
**What it is:** The type of Kubernetes object

```yaml
kind: Pod               # A single container/group of containers
kind: Deployment        # Multiple Pods managed automatically
kind: Service           # Network load balancer for Pods
kind: Ingress          # HTTP router for multiple Services
kind: ConfigMap        # Store configuration data
kind: Secret           # Store sensitive data
kind: PersistentVolume # Storage volumes
kind: Node             # A server in the cluster
kind: Namespace        # Virtual cluster within cluster
```

**Most common:** Deployment (you'll use this 80% of the time)

### 3. metadata
**What it is:** Data ABOUT the object (not about what it does, but WHO it is)

```yaml
metadata:
  name: my-nginx                  # Unique name in the namespace
  namespace: default              # Which namespace (default if omitted)
  labels:
    app: nginx                    # Key-value labels for organization
    environment: production
    version: v1
  annotations:
    description: "Web server"     # More descriptive labels
    contact: "devops@company.com"
```

**Common fields:**
- `name`: Required. Name of the object (used with `kubectl get`)
- `namespace`: Which namespace (default if omitted)
- `labels`: Key-value pairs for organizing/selecting objects
- `annotations`: Human-readable notes (not used for selection)

**Labels example:**
```yaml
labels:
  app: my-app           # What app is this?
  tier: frontend        # Frontend, backend, database?
  version: v1           # Which version?
  environment: prod     # Production or staging?
  team: platform-eng    # Which team owns this?
```

Service uses labels to find Pods:
```yaml
# Service says: "Find all Pods with label app: my-app"
selector:
  app: my-app
```

### 4. spec
**What it is:** The actual specification (what you want this object to do)

**Different kinds have different spec formats:**

#### Pod spec:
```yaml
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
```

#### Deployment spec:
```yaml
spec:
  replicas: 3              # How many Pods?
  selector:                # Which Pods does this Deployment manage?
    matchLabels:
      app: my-app
  template:                # Pod template (the blueprint)
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
```

#### Service spec:
```yaml
spec:
  type: ClusterIP          # Type of service
  ports:
    - port: 80             # Service port
      targetPort: 8080     # Container port
  selector:
    app: my-app            # Select Pods with this label
```

---

## Annotated Real-World Examples

### Example 1: Simple Pod

```yaml
# What version of API?
apiVersion: v1

# What type of object?
kind: Pod

# Who am I?
metadata:
  name: nginx-pod              # Name of this Pod
  namespace: default           # Kubernetes namespace
  labels:                       # Labels for organization/selection
    app: web                    # This Pod is part of "web" app
    tier: frontend              # It's a frontend component
    
spec:                           # What do I want?
  containers:                   # List of containers
    - name: nginx               # Container name (unique in this Pod)
      image: nginx:1.25         # Docker image
      imagePullPolicy: IfNotPresent  # Only pull if not already local
      ports:                    # Ports this container listens on
        - containerPort: 80     # HTTP port
          name: http            # Name this port (optional)
        - containerPort: 443    # HTTPS port
          name: https
      resources:                # CPU/memory requests and limits
        requests:
          cpu: 100m             # Request 100 millicores CPU
          memory: 128Mi         # Request 128 MB memory
        limits:
          cpu: 200m             # Max 200 millicores CPU
          memory: 256Mi         # Max 256 MB memory
      env:                      # Environment variables
        - name: LOG_LEVEL
          value: "INFO"
      readinessProbe:           # Is the container ready for traffic?
        httpGet:
          path: /               # Check this path
          port: 80              # On this port
        initialDelaySeconds: 5  # Wait 5 seconds before first check
        periodSeconds: 10       # Check every 10 seconds
      livenessProbe:            # Is the container alive?
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 15
        periodSeconds: 20
```

### Example 2: Deployment

```yaml
apiVersion: apps/v1      # Apps API

kind: Deployment         # Deployment object (manages Pods)

metadata:
  name: nginx-app        # Name of the Deployment
  labels:
    app: nginx
    version: v1

spec:
  replicas: 3            # Run 3 copies of this Pod
  
  selector:              # Which Pods does this Deployment manage?
    matchLabels:
      app: nginx         # Manage Pods with label "app: nginx"
  
  strategy:              # How to roll out updates
    type: RollingUpdate  # Replace old Pods with new gradually
    rollingUpdate:
      maxSurge: 1        # Allow 1 extra Pod during update
      maxUnavailable: 1  # Allow 1 Pod to be down during update
  
  template:              # Pod template (blueprint for Pods)
    metadata:
      labels:
        app: nginx       # Label Pods with this
        version: v1
    
    spec:                # Pod specification
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
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
          volumeMounts:           # Mount volumes into container
            - name: config        # Volume name (defined below)
              mountPath: /etc/nginx/conf.d  # Mount path
      
      volumes:                    # Define volumes to attach
        - name: config            # Volume name
          configMap:              # Volume type (ConfigMap)
            name: nginx-config    # Name of the ConfigMap
```

### Example 3: Service

```yaml
apiVersion: v1

kind: Service           # Network load balancer

metadata:
  name: nginx-service   # Name of the Service
  labels:
    app: nginx

spec:
  type: LoadBalancer    # Type: ClusterIP (internal), NodePort (external), LoadBalancer (cloud)
  
  selector:             # Which Pods does this Service route to?
    app: nginx          # Select Pods with label "app: nginx"
  
  ports:                # Port mappings
    - name: http        # Port name
      protocol: TCP     # Protocol (TCP or UDP)
      port: 80          # Service port (what you call it)
      targetPort: 80    # Pod port (what the container listens on)
  
  sessionAffinity: ClientIP  # Optional: stick client to same Pod
```

---

## Common YAML Fields Reference

### Container Specification:

```yaml
containers:
  - name: app-container
    image: my-app:1.0                    # Docker image
    imagePullPolicy: IfNotPresent        # Pull policy
    ports:
      - containerPort: 3000              # Port inside container
        protocol: TCP                    # TCP or UDP
    env:                                 # Environment variables
      - name: DATABASE_URL
        value: "postgres://db:5432"
      - name: API_KEY
        valueFrom:
          secretKeyRef:
            name: api-secret
            key: token
    resources:
      requests:
        cpu: 100m                        # Minimum CPU (0.1 cores)
        memory: 128Mi                    # Minimum memory (128 MB)
      limits:
        cpu: 500m                        # Maximum CPU (0.5 cores)
        memory: 512Mi                    # Maximum memory (512 MB)
    readinessProbe:                      # Is it ready for traffic?
      httpGet:
        path: /health
        port: 3000
      initialDelaySeconds: 10
      periodSeconds: 5
    livenessProbe:                       # Is it alive?
      httpGet:
        path: /status
        port: 3000
      initialDelaySeconds: 30
      periodSeconds: 10
    volumeMounts:
      - name: data
        mountPath: /data
```

### Deployment Specification:

```yaml
spec:
  replicas: 3                            # Number of Pods
  selector:
    matchLabels:
      app: my-app                        # Select Pods with this label
  strategy:
    type: RollingUpdate                  # Or Recreate
    rollingUpdate:
      maxSurge: 1                        # Extra Pods during update
      maxUnavailable: 0                  # Pods that can be down
  progressDeadlineSeconds: 600           # Timeout for deployment
  template:
    # Pod template (same as Pod spec)
```

---

## YAML Tips & Tricks

### 1. Indentation is Critical
```yaml
# ✅ Correct (2 spaces)
metadata:
  name: my-pod
  labels:
    app: web

# ❌ Wrong (inconsistent indentation)
metadata:
  name: my-pod
labels:
  app: web

# ❌ Wrong (tabs instead of spaces)
metadata:
	name: my-pod
```

**Rule:** Use 2 or 4 spaces. Be consistent. Never use tabs.

### 2. List Items (Dashes)
```yaml
# ✅ Correct
containers:
  - name: app
    image: nginx
  - name: sidecar
    image: busybox

# ❌ Wrong (no dash)
containers:
  name: app
  image: nginx
```

### 3. Quotes for Strings
```yaml
# ✅ All correct
port: 8080               # Number (no quotes)
name: my-app            # String (no quotes needed for simple strings)
description: "Hello"    # String (quotes optional)
path: "/data"           # String (quotes optional)
enabled: true           # Boolean (no quotes)

# ⚠️ Strings that look like other types
port: "8080"            # String "8080" (in quotes) vs number 8080
version: "1.0.0"        # String "1.0.0" (in quotes) vs might be parsed as number
```

### 4. Check YAML Syntax
```bash
# Validate YAML without applying
kubectl apply -f deployment.yaml --dry-run=client

# Check syntax (kubeval tool)
kubeval deployment.yaml

# See what would be applied
kubectl apply -f deployment.yaml -v=2
```

### 5. Multiple Resources in One File
```yaml
---  # Separator (three dashes)
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
spec:
  containers:
    - image: nginx

---  # Separator
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: nginx
```

```bash
# Apply all resources from file
kubectl apply -f file-with-multiple.yaml
```

### 6. Check What Was Applied
```bash
# See YAML as kubectl stored it
kubectl get pod my-pod -o yaml

# Compare desired (YAML) vs current (cluster)
kubectl diff -f deployment.yaml
```

---

## Common YAML Mistakes

### ❌ Mistake 1: Wrong indentation
```yaml
# Wrong
spec:
containers:      # Should be indented
  - name: app

# Right
spec:
  containers:    # Indented under spec
    - name: app
```

### ❌ Mistake 2: Missing required field
```yaml
# Wrong (no containers field)
spec:
  replicas: 3

# Right
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: app
          image: nginx
```

### ❌ Mistake 3: Type mismatch
```yaml
# Wrong (replicas should be number, not string)
spec:
  replicas: "3"

# Right
spec:
  replicas: 3
```

### ❌ Mistake 4: Wrong selector
```yaml
# Wrong (selector doesn't match template labels)
spec:
  selector:
    matchLabels:
      app: nginx          # Selector looks for this label
  template:
    metadata:
      labels:
        app: web          # But template has different label

# Right
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx        # Must match selector
```

---

## YAML vs kubectl Imperative Commands

### Imperative (Commands):
```bash
# Create directly with commands (no YAML)
kubectl run my-pod --image=nginx:1.25
kubectl expose pod my-pod --port=80 --target-port=80
kubectl scale deployment my-app --replicas=5

# Pros: Quick for testing
# Cons: No version control, hard to reproduce
```

### Declarative (YAML):
```bash
# Describe in YAML file, apply it
kubectl apply -f deployment.yaml

# Pros: Version control, reproducible, infrastructure-as-code
# Cons: Need to write YAML
```

**Rule:** Use YAML for anything production-like. Use imperative commands only for quick testing.

---

## Key Takeaway

**YAML structure:**
```
apiVersion: v1              # What API version?
kind: Pod                   # What type of object?
metadata:                   # Metadata (name, labels)
  name: my-pod
  labels:
    app: my-app
spec:                       # Specification (how does it work?)
  containers:
    - name: app
      image: nginx:1.25
```

**Remember:**
- apiVersion + kind = what you're creating
- metadata = who/what is it
- spec = how does it work
- Indentation matters (2 spaces)
- Labels are how Kubernetes organizes and selects Pods

---

## Next Step

👉 You've finished the getting-started section! You now understand:
- ✅ What Kubernetes is (Module 01)
- ✅ What Docker & containers are (Module 02)
- ✅ What a Pod is (Module 03)
- ✅ What kubectl is (Module 04)
- ✅ Kubernetes architecture (Module 05)
- ✅ YAML syntax (Module 06)

**Ready for the real stuff?**

Go to [LEARNING-PATH.md](../LEARNING-PATH.md) and start Module 01: Core Concepts
