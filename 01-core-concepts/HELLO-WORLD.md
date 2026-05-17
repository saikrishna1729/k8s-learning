# 👋 Hello World — Module 01

**Goal:** Deploy your first Pod and Deployment. Understand Pods, restarts, and rolling updates.

**Time:** 10 minutes

---

## Step 1: Deploy a Single Pod

```bash
# Apply the simplest Pod
kubectl apply -f hello-world-pod.yaml

# View the Pod
kubectl get pods

# Check its status
kubectl describe pod hello-world-pod

# See logs
kubectl logs hello-world-pod
```

**What happened:**
- Kubernetes created a Pod running nginx
- The Pod has a unique, internal IP address
- nginx is listening on port 80 inside the container

---

## Step 2: Kill the Pod and Watch It NOT Restart

```bash
# Delete the pod (bye forever!)
kubectl delete pod hello-world-pod

# Check that it's gone
kubectl get pods
# Output: No resources found (it's deleted)
```

**Key Learning:** Bare Pods don't restart when deleted—they're gone forever. This is why we use Deployments (next step) which automatically create replacement Pods.

---

## Step 3: Deploy a Deployment (Restarts Pods Automatically)

```bash
# Apply the Deployment
kubectl apply -f hello-world-deployment.yaml

# View the Deployment
kubectl get deployments

# View Pods created by the Deployment
kubectl get pods

# Notice the Pod names have random suffixes (e.g., hello-world-xyz123)
```

**What happened:**
- Kubernetes created a Deployment
- The Deployment created 2 Pod replicas (as specified)
- Each Pod has a name like `hello-world-abc123`

---

## Step 4: Kill a Pod and Watch the Deployment Replace It

```bash
# List Pods and their names
kubectl get pods
# Output:
# NAME                          READY   STATUS    RESTARTS   AGE
# hello-world-abc123            1/1     Running   0          2m
# hello-world-def456            1/1     Running   0          2m

# Copy one of the Pod names from above (e.g., hello-world-abc123)
# and delete it
kubectl delete pod hello-world-abc123

# Immediately list Pods again
kubectl get pods
# Notice: the old Pod is gone (Terminating)
# But a NEW Pod was created! (notice new name like hello-world-ghi789)

# Keep checking for 10 seconds—see the new Pod become Ready
kubectl get pods -w
# Press Ctrl+C to stop watching
```

**Key Learning:** Deployments maintain desired replicas. When you delete a Pod, Deployment automatically creates a replacement. This is why Deployments are better than bare Pods.

---

## Step 5: Scale the Deployment

```bash
# Scale to 5 replicas
kubectl scale deployment hello-world --replicas 5

# Check Pods
kubectl get pods

# You should see 5 Pods now
```

**Key Learning:** You can change `replicas` without redeploying.

---

## Step 6: Update the Image (Rolling Update)

```bash
# Change the image to a different nginx version
kubectl set image deployment/hello-world hello=nginx:1.26

# Watch the rollout progress
kubectl rollout status deployment/hello-world

# Check Pods (you'll see both old and new ones during the update)
kubectl get pods
```

**Key Learning:** Kubernetes rolls out updates gradually (not all at once), so traffic keeps flowing.

---

## Step 7: Rollback If Something Goes Wrong

```bash
# View the rollout history
kubectl rollout history deployment/hello-world

# Rollback to the previous version
kubectl rollout undo deployment/hello-world

# Watch the rollback
kubectl rollout status deployment/hello-world
```

**Key Learning:** Deployments keep old versions so you can rollback instantly.

---

## Step 8: Clean Up

```bash
# Delete the Deployment (this also deletes all its Pods)
kubectl delete deployment hello-world

# Verify it's gone
kubectl get deployments
kubectl get pods
```

---

## 🎓 What You Learned

✅ Pods are the smallest unit in Kubernetes  
✅ Pod IPs are ephemeral (change on restart)  
✅ Deployments keep Pods running (replace them if they die)  
✅ You can scale replicas up/down without redeploying  
✅ Rolling updates keep traffic flowing  
✅ Rollback is instant—old replicas are kept  

---

## Next Steps

1. Read the full README.md to understand the concepts deeper
2. Try modifying the YAML files (e.g., change `replicas: 2` to `replicas: 3`)
3. Move to Module 02 (Services) when you're comfortable with Pods and Deployments
