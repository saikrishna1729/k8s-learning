# PersistentVolumes, PersistentVolumeClaims & Storage

## Concepts

### PersistentVolume (PV)
- **Cluster-level** storage resource (independent of Pods)
- Created by admin or dynamically by provisioner
- Has a lifecycle separate from Pods
- Example: 10GB AWS EBS volume, NFS share, local disk

### PersistentVolumeClaim (PVC)
- **Pod's request** for storage
- Binds to a matching PV
- 1:1 relationship (one PVC → one PV)
- Survives Pod deletion (storage persists)

### StorageClass
- **Template** for dynamic PV provisioning
- Specifies provisioner (AWS EBS, Azure Disks, NFS, etc.)
- Parameters: size, IOPS, encryption, reclaim policy
- When PVC created, provisioner automatically creates matching PV

### Binding
- PVC searches for matching PV (size, access mode, storage class)
- Once bound, exclusive (other PVCs can't use same PV)
- If no matching PV exists and StorageClass defined → auto-create PV

---

## Access Modes

| Mode | Symbol | Use Case |
|------|--------|----------|
| **ReadWriteOnce** | RWO | Single pod reads & writes (EBS, Azure Disk, local) |
| **ReadOnlyMany** | ROX | Multiple pods read (shared config) |
| **ReadWriteMany** | RWX | Multiple pods read & write (NFS, EFS) |

**Note:** Not all storage supports all modes. EBS = RWO only. NFS = all three.

---

## Reclaim Policy

What happens when PVC is deleted:

| Policy | Behavior |
|--------|----------|
| **Retain** | PV stays (manual cleanup needed) |
| **Delete** | PV deleted (default for dynamic) |
| **Recycle** | Deprecated; data wiped but PV reused |

Use **Retain** for important data (databases, backups).
Use **Delete** for ephemeral storage (caches, logs).

---

## Manual PV + PVC (Static Provisioning)

See `pv-pvc-manual.yaml` for example.

**Steps:**
1. Create PV (admin): define capacity, access mode, storage backend
2. Create PVC (dev): request storage from matching PV
3. Use PVC in Pod: reference PVC name in volume

**Drawback:** Admin must pre-create PVs; wastes storage if underutilized.

```bash
kubectl apply -f pv-pvc-manual.yaml
kubectl get pv
kubectl get pvc
```

---

## Dynamic Provisioning (StorageClass)

See `storageclass-dynamic.yaml` for example.

**Steps:**
1. Define StorageClass (admin): provisioner + parameters
2. Create PVC (dev): references StorageClass name
3. Provisioner auto-creates PV matching PVC
4. Use PVC in Pod

**Advantages:** On-demand provisioning, no pre-created PVs, better resource utilization.

```bash
kubectl apply -f storageclass-dynamic.yaml
kubectl get sc
kubectl get pvc
kubectl get pv
```

### Common StorageClass Provisioners

**AWS EKS:**
```yaml
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
```

**Azure AKS:**
```yaml
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
  fstype: ext4
```

**Google GKE:**
```yaml
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

**NFS (any cluster):**
```yaml
provisioner: nfs.io/efs
parameters:
  server: nfs-server.example.com
  path: /exports
```

---

## StatefulSets with Persistent Storage

See `statefulset-with-storage.yaml` for MySQL example.

StatefulSet pods need **stable, persistent identity**. Use `volumeClaimTemplates`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql  # headless service name (required)
  replicas: 3
  template:
    spec:
      containers:
      - volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      storageClassName: fast-storage
      accessModes: [ ReadWriteOnce ]
      resources:
        requests:
          storage: 20Gi
```

**Result:** Each StatefulSet pod gets its own PVC + PV:
- `mysql-0` → `data-mysql-0` PVC → PV
- `mysql-1` → `data-mysql-1` PVC → PV
- `mysql-2` → `data-mysql-2` PVC → PV

Pod identity stable: if `mysql-0` restarts, same PVC reused (data persists).

---

## Common Operations

### List PVs and PVCs

```bash
# All PVs in cluster
kubectl get pv

# All PVCs in all namespaces
kubectl get pvc -A

# Describe PVC (see binding status)
kubectl describe pvc my-pvc

# Check PV status
kubectl get pv -o wide
```

### Expand PVC

```bash
# Edit PVC, increase storage request
kubectl edit pvc my-pvc

# In spec.resources.requests.storage, change to larger value (e.g., 20Gi)
# File system auto-expands if StorageClass has allowVolumeExpansion: true
```

### Delete PVC (and PV if reclaim policy = Delete)

```bash
kubectl delete pvc my-pvc

# If PV still exists (Retain policy), delete manually
kubectl delete pv my-pv
```

### Mount PVC as readonly

```yaml
volumeMounts:
- name: data
  mountPath: /data
  readOnly: true  # pod can read but not write
```

---

## Troubleshooting

### PVC stuck in "Pending"

```bash
kubectl describe pvc my-pvc
# Check Events section for error (no matching PV, provisioner failed, etc.)
```

**Causes:**
- No matching PV (static) → create PV
- StorageClass provisioner missing → install provisioner
- Insufficient storage → increase size or delete unused PVCs

### PVC not mounting in Pod

```bash
# Check pod status
kubectl describe pod my-pod

# Check mounted volumes
kubectl exec -it my-pod -- mount | grep /data
```

### Slow I/O

- Check IOPS/throughput in StorageClass
- Verify StorageClass provisioner matches storage backend
- Check node EBS/disk limits

---

## Production Best Practices

1. **Set reclaim policy to Retain** for databases, backups, critical data
2. **Use dynamic provisioning** (StorageClass) instead of manual PVs
3. **Monitor PVC usage** — set alerts before 80% full
4. **Plan for expansion** — allowVolumeExpansion: true; increase size before hitting limit
5. **Backup strategy** — PVCs don't auto-backup; use snapshots/external backups
6. **Multi-AZ** — for high availability, use regional storage or replicated backends
7. **Encrypt at rest** — enable EBS/disk encryption in StorageClass parameters

---

## Summary Table

| Feature | PV | PVC | StorageClass |
|---------|-----|-----|--------------|
| **Scope** | Cluster | Namespace | Cluster |
| **Who creates** | Admin | Dev (or auto) | Admin |
| **Lifecycle** | Independent | Tied to PVC | Template |
| **Use case** | Provisioning | Requesting | Dynamic provisioning |
| **Binding** | 1 PV → many PVs | 1 PVC → 1 PV | 0..* PVCs → auto PVs |
