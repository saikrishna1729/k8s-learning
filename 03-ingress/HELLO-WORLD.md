# 👋 Hello World — Module 03

**Goal:** Route traffic to multiple services via Ingress. Understand path-based routing with one LoadBalancer.

**Time:** 10 minutes

**Prerequisites:** Completed Modules 01-02

---

## Step 1: Install NGINX Ingress Controller

```bash
# Install NGINX controller (if not already installed)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

# Verify installation
kubectl get pods -n ingress-nginx

# Wait for the controller to be ready (this takes ~30 seconds)
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

---

## Step 2: Deploy Multiple Services

```bash
# Apply frontend Deployment + backend Deployment + Ingress
kubectl apply -f hello-world-ingress.yaml

# View Deployments
kubectl get deployments

# View Services
kubectl get services

# View Ingress
kubectl get ingress

# Get Ingress details
kubectl describe ingress hello-world
```

**What happened:**
- Created 2 Deployments (frontend, backend)
- Created 2 Services (frontend-service, backend-service)
- Created 1 Ingress that routes:
  - `/` → frontend-service
  - `/api` → backend-service

---

## Step 3: Test Routing

### Option A: Local Port-Forward (Easy)

```bash
# Port-forward to the NGINX Ingress Controller
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# In another terminal, test routing
# Root path goes to frontend
curl http://localhost:8080/

# /api path goes to backend
curl http://localhost:8080/api
```

### Option B: Get External IP (Depends on Cluster Type)

```bash
# Check if your Ingress got an external IP
kubectl get ingress hello-world -o wide

# On cloud (AWS/Azure/GCP), this shows the LoadBalancer IP
# On local minikube/OrbStack, you may need port-forward instead
```

### Option C: Modify Local Hosts File (Mac/Linux)

```bash
# Get the Ingress Controller LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Edit /etc/hosts (requires sudo)
# Add this line:
# <external-ip> myapp.local

# Then access via hostname
# curl http://myapp.local/
# curl http://myapp.local/api
```

---

## Step 4: Understand the Traffic Flow

```
User Request to http://myapp.local/api
  ↓
NGINX Ingress Controller (load balancer) receives request
  ↓
Checks routing rules: path=/api → backend-service
  ↓
Forwards to backend-service
  ↓
backend-service load-balances across backend Pods
  ↓
Backend Pod responds
```

**Key Learning:** One LoadBalancer (Ingress Controller) routes to multiple Services.

---

## Step 5: Test Multiple Replicas

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas 3

# Check Pods
kubectl get pods

# Hit /api multiple times and watch the requests distribute
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# In another terminal:
for i in {1..10}; do curl http://localhost:8080/api; echo ""; done

# Check backend Pod logs to see load balancing
kubectl logs -l app=backend

# All 3 Pods should have some requests
```

---

## Step 6: Add Host-Based Routing (Bonus)

```bash
# Create host-based Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-host
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: frontend.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  - host: api.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
EOF

# Add hosts to /etc/hosts
# <external-ip> frontend.myapp.local
# <external-ip> api.myapp.local

# Test host-based routing
curl http://frontend.myapp.local/
curl http://api.myapp.local/
```

**Key Learning:** Ingress supports both path-based AND host-based routing.

---

## Step 7: View Ingress Controller Logs

```bash
# See how NGINX routes traffic
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# You'll see lines like:
# <ip> - <user> [...] "GET /api HTTP/1.1" 200 612
```

---

## Step 8: Clean Up

```bash
# Delete everything
kubectl delete ingress hello-world hello-world-host
kubectl delete deployment frontend backend
kubectl delete service frontend-service backend-service

# Verify
kubectl get pods
kubectl get svc
kubectl get ingress
```

---

## 🎓 What You Learned

✅ Ingress routes traffic based on path and hostname  
✅ One LoadBalancer (Ingress Controller) serves multiple backends  
✅ Path-based routing: `/` → frontend, `/api` → backend  
✅ Host-based routing: `frontend.myapp.local` → frontend  
✅ Ingress Controller must be installed before Ingress works  
✅ Ingress finds Services via the `backend` section  

---

## Cost Savings

**Without Ingress:**
- 2 Services → 2 LoadBalancers → $32/month

**With Ingress:**
- 2 Services + 1 Ingress → 1 LoadBalancer → $16/month

**Savings: $16/month per pair of services!**

---

## Next Steps

1. Read the full README.md
2. Try different pathTypes (Exact vs Prefix)
3. Move to Module 04 (Config Management) when comfortable
