# 👋 Hello World — Module 02

**Goal:** Expose a Deployment via a Service. Understand stable DNS and load balancing.

**Time:** 10 minutes

**Prerequisites:** Completed Module 01

---

## Step 1: Deploy Deployment + Service

```bash
# Apply both Deployment and Service
kubectl apply -f hello-world-clusterip.yaml

# View Deployment
kubectl get deployments

# View Service
kubectl get services

# Get Service details
kubectl describe service hello-world-service
```

**What happened:**
- Deployment created 2 Pods with label `app: hello-world`
- Service found those Pods via the label selector
- Service assigned a stable DNS name: `hello-world-service.default.svc.cluster.local`
- Service created an `Endpoints` object tracking Pod IPs

---

## Step 2: Verify Service DNS Resolves Inside the Cluster

### Why test from inside a Pod?

Services are **internal-only by default**. They only have DNS names inside the cluster. From your computer, you can't reach them. We create a temporary test Pod to prove the Service DNS works from inside the cluster.

### Create a test Pod and access the Service:

```bash
# Launch a temporary test Pod
kubectl run -it test-pod --image=ubuntu:latest -- /bin/bash

# You're now INSIDE the test Pod (notice the new prompt)
# Install tools to test the Service
apt-get update && apt-get install -y curl dnsutils

# Test 1: Check if DNS resolves
# (nslookup looks up hostnames and returns IP addresses)
nslookup hello-world-service
# You should see:
# Name: hello-world-service
# Address: 10.x.x.x (some internal IP)

# Test 2: Try to access the Service via HTTP
# (curl makes HTTP requests, like visiting a website)
curl http://hello-world-service
# You should see the nginx welcome page (HTML)

# Test 3: Same test but with the full DNS name
curl http://hello-world-service.default.svc.cluster.local
# Should also work

# Exit the test Pod
exit
```

**Key Learning:** Services provide stable DNS names inside the cluster, even though underlying Pod IPs change.

### What just happened?

1. We created a temporary Pod running Ubuntu
2. Inside that Pod, we used `nslookup` to look up the Service's IP address
3. We used `curl` to make HTTP requests to the Service
4. The Service load-balanced our request to one of the backend Pods
5. We exited, and the test Pod was deleted (it was temporary)

---

## Step 3: Kill a Pod and Watch Service Update Automatically

```bash
# In a terminal, watch Pods
kubectl get pods -w

# In another terminal, delete a Pod
kubectl delete pod <pod-name>

# Watch as:
# 1. Pod goes Terminating
# 2. New Pod is created
# 3. Service Endpoints update automatically (happens in ~10 seconds)
```

**Key Learning:** Services automatically track Pods as they restart.

---

## Step 4: Test Load Balancing

```bash
# Get the Service IP
kubectl get svc hello-world-service -o wide

# Launch a test Pod with curl in a loop
kubectl run -it test-pod --image=ubuntu:latest -- bash

# Inside the test Pod, curl the Service multiple times
apt-get update && apt-get install -y curl

# Hit the Service 10 times, watch which Pod handles it
for i in {1..10}; do curl http://hello-world-service; echo ""; done

# Check the nginx logs on each Pod to see traffic distribution
exit

# From your machine, check logs on both Pods
kubectl logs <pod-name-1>
kubectl logs <pod-name-2>

# Both Pods should have some requests logged
```

**Key Learning:** Service load-balances traffic across all Pods.

---

## Step 5: Scale Deployment and Watch Service Update

```bash
# Scale to 5 replicas
kubectl scale deployment hello-world --replicas 5

# View Pods
kubectl get pods

# Check Service Endpoints (it should now show 5 IPs)
kubectl describe service hello-world-service

# Test load balancing again
kubectl run -it test-pod --image=ubuntu:latest -- bash
apt-get update && apt-get install -y curl
for i in {1..20}; do curl http://hello-world-service; echo ""; done
exit
```

**Key Learning:** Service Endpoints auto-update when Pods scale.

---

## Step 6: Try Different Service Types

### NodePort (External Access)

```bash
# Create a NodePort Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: hello-world-nodeport
  namespace: default
spec:
  type: NodePort
  selector:
    app: hello-world
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001
EOF

# Get the Service
kubectl get service hello-world-nodeport

# Note the nodePort (30001)
# Try to access it from your machine
# On Mac/Linux with minikube:
minikube service hello-world-nodeport

# On other setups, get a node IP and visit http://<node-ip>:30001
kubectl get nodes -o wide
```

**Key Learning:** NodePort exposes the Service on every Node, accessible externally.

---

## Step 7: Clean Up

```bash
# Delete everything
kubectl delete -f hello-world-clusterip.yaml
kubectl delete service hello-world-nodeport
kubectl delete pod test-pod

# Verify gone
kubectl get pods
kubectl get svc
```

---

## 🎓 What You Learned

✅ Services provide stable DNS for Pods  
✅ Services find Pods via label selectors  
✅ Services auto-update Endpoints when Pods change  
✅ ClusterIP = internal only  
✅ NodePort = external access via Node IP  
✅ Service distributes traffic across all matching Pods  

---

## Next Steps

1. Read the full README.md
2. Experiment with different selectors and labels
3. Move to Module 03 (Ingress) when comfortable with Services
