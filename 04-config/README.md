# 🔐 04 - Config Management

## ConfigMap vs Secret
- ConfigMap = non-sensitive config (stored as plain text in etcd)
- Secret = sensitive config (stored as base64 in etcd)
- Base64 is NOT encryption — anyone can decode it!
- Real security = RBAC + etcd encryption at rest

## Injection Patterns
1. env / envFrom   → needs pod RESTART to pick up changes
2. Volume Mount    → updates AUTOMATICALLY (~60s sync)

## Production Secret Management
- Never commit Secret YAMLs to git!
- Use External Secrets Operator + AWS SSM / HashiCorp Vault
- Always mount secrets as readOnly volumes
- Restrict access with RBAC

## Storage (PersistentVolumes & PersistentVolumeClaims)
- **PersistentVolume (PV)** — cluster-level storage resource (abstraction over AWS EBS, Azure Disks, NFS, etc.)
- **PersistentVolumeClaim (PVC)** — Pod's request for storage (like a "claim ticket" for a PV)
- **StorageClass** — template for dynamic PV provisioning (AWS EBS gp3, Azure Standard, etc.)
- **Binding** — PVC binds to matching PV; once bound, exclusive (one PVC per PV)
- **Dynamic Provisioning** — PVC automatically creates PV if StorageClass exists (no manual PV creation needed)
- **Reclaim Policy** — what happens to PV when PVC deleted: Retain (keep), Delete (remove), Recycle (deprecated)
- **StatefulSet** — workload that needs persistent storage; uses volumeClaimTemplates for auto PVC per pod

## Access Modes
- **ReadWriteOnce (RWO)** — one pod can read & write (most common for block storage: EBS, Azure Disks)
- **ReadOnlyMany (ROX)** — many pods read-only
- **ReadWriteMany (RWX)** — many pods read & write (NFS, EFS, file-based storage; slow)

## Subdirectories
- `configmaps/` — ConfigMap examples
- `secrets/` — Secret examples
- `storage/` — PV, PVC, StorageClass examples (local, dynamic, StatefulSet)
