# Pod Security Admission (PSA)

Pod Security Admission replaces the deprecated Pod Security Policy (PSP). It enforces Pod security standards at the namespace level via labels.

## Three Policy Levels

### 1. `privileged` (Default)
- Allows everything
- No restrictions
- Example: kernel modules, host networking, privileged containers

### 2. `baseline`
- Minimally restrictive
- Blocks dangerous features (privileged containers, root privileges)
- Allows common use cases (initContainers, volume types, etc.)
- Default for most workloads

### 3. `restricted`
- Strictest profile
- Requires:
  - Containers run as non-root
  - Read-only root filesystem
  - Drop dangerous capabilities
  - Deny privilege escalation
- Best for sensitive workloads

## Enable PSA on a Namespace

```bash
# Enforce 'baseline' — reject Pods that don't meet baseline standard
kubectl label namespace default pod-security.kubernetes.io/enforce=baseline --overwrite

# Audit 'restricted' — allow Pods but log warnings if they don't meet restricted
kubectl label namespace default pod-security.kubernetes.io/audit=restricted --overwrite

# Warn on 'restricted' — show warnings to users if they deploy non-compliant Pods
kubectl label namespace default pod-security.kubernetes.io/warn=restricted --overwrite
```

## Example: Create a Pod that Violates Baseline

```bash
kubectl run privileged-pod --image=nginx:1.25 -- bash -c "sleep 3600" \
  --overrides='{"spec": {"containers": [{"name": "nginx", "securityContext": {"privileged": true}}]}}'

# This pod will be rejected with:
# Error: pods "privileged-pod" is forbidden: violates PodSecurity "baseline:latest": 
# privileged (container "nginx" must not set securityContext.privileged=true)
```

## Example: Create a Pod that Meets Restricted

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: default
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.25
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: var-cache
      mountPath: /var/cache/nginx
  volumes:
  - name: tmp
    emptyDir: {}
  - name: var-cache
    emptyDir: {}
```

## Label Modes

Each label can be set independently:

| Label | Behavior |
|-------|----------|
| `enforce` | Reject Pods that violate the standard |
| `audit` | Allow Pods but add audit event |
| `warn` | Allow Pods but warn the user |

Example:

```bash
# Enforce 'restricted', audit 'restricted', warn on violations
kubectl label namespace secure-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted --overwrite
```

## Exemptions

To exempt certain Pods (e.g., system components), use the following label on the namespace:

```bash
kubectl label namespace kube-system \
  pod-security.kubernetes.io/exempt=kube-system --overwrite
```

Or add exemption rules in the API server configuration (advanced).

## Migration from PSP

If you had Pod Security Policies:

1. Identify which PSPs were enforced
2. Map them to PSA levels (usually `baseline` or `restricted`)
3. Label namespaces accordingly
4. Test thoroughly
5. Disable PSP in API server config once validated

See: https://kubernetes.io/docs/tasks/configure-pod-container/migrate-from-psp/
