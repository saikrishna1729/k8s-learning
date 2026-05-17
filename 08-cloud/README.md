# ☁️ 08 - Cloud

> **This module takes your app to production.** Choose between AWS (EKS), Azure (AKS), or Google Cloud (GKE) and deploy your Kubernetes cluster to the cloud.

## ⏱️ Estimated Time: 3-5 hours | Difficulty: ⭐⭐ Intermediate

## 🎯 Problem This Solves

From Module 07: Your app works perfectly on your local cluster. But **local clusters aren't production**—they're single-node, data doesn't survive restarts, and you have no multi-zone resilience.

**Answer:** Managed Kubernetes services (EKS/AKS/GKE) that handle control plane, automatic updates, backups, and multi-AZ failover.

## 📋 Prerequisites

- Modules 01-07 (complete understanding of K8s)
- Cloud account (AWS, Azure, or Google Cloud) with credit card
- CLI tools installed: `aws`, `az`, or `gcloud`

---

## 🛣️ Decision Tree: Which Cloud?

### **AWS (EKS) — Most comprehensive & industry standard**

**Choose if:**
- You use AWS services (S3, RDS, DynamoDB, Lambda)
- Your company standardizes on AWS
- You want the widest ecosystem of tools
- You need specific AWS integrations (ALB, IAM roles, EBS snapshots)

**Benefits:**
- Mature ecosystem (many tools built for EKS)
- IRSA (IAM Roles for Service Accounts) for fine-grained permissions
- Native ALB/NLB load balancers
- EBS volumes with snapshots

**Downsides:**
- Most expensive (control plane ~$0.10/hour + nodes)
- Steeper learning curve (IAM, security groups, subnets)
- **Module 08/eks/ has full setup guide with Terraform**

---

### **Azure (AKS) — Best for Microsoft shops**

**Choose if:**
- You use Azure services (SQL, Cosmos DB, App Service)
- Your company standardizes on Microsoft
- You have Azure AD for identity management
- You want tight integration with Office 365 / Dynamics

**Benefits:**
- Azure AD integration out-of-the-box
- Simpler RBAC (uses Azure AD instead of Kubernetes RBAC)
- Managed identity is simpler than IRSA

**Downsides:**
- Smaller ecosystem than AWS
- Less community content online
- **Module 08/aks/ has minimal setup guide; add more if needed**

---

### **Google Cloud (GKE) — Most Kubernetes-native**

**Choose if:**
- You like Google's approach (Kubernetes was created at Google)
- You want Autopilot (fully serverless K8s, no node management)
- You need Datadog/Stackdriver logging out-of-the-box
- You're experimenting or learning (free tier available)

**Benefits:**
- Most "cloud-native"—tight integration with K8s ecosystem
- Autopilot is truly serverless (no node management)
- Built-in logging and monitoring
- Free tier for learning

**Downsides:**
- Smaller than AWS/Azure for enterprise
- Less third-party integrations than AWS
- **Module 08/gke/ has minimal setup guide; add more if needed**

---

## 📊 Quick Comparison

| Feature | EKS | AKS | GKE |
|---------|-----|-----|-----|
| **Control Plane Cost** | ~$0.10/hour | ~$0.10/hour | Free |
| **Node Pricing** | Standard EC2 | Standard VMs | Standard GCE |
| **Identity** | IAM + IRSA | Azure AD + Managed Identity | Service Accounts + Workload Identity |
| **Load Balancer** | ALB/NLB (AWS) | Azure LB | Cloud LB |
| **Storage** | EBS | Azure Disks | Persistent Disks |
| **Community** | Largest | Medium | Medium |
| **Autopilot** | No | No | Yes |
| **Difficulty** | ⭐⭐ | ⭐ | ⭐ |

---

## 📂 Subdirectories

- **`eks/`** — [EKS (AWS)](./eks/)  
  Comprehensive guide: eksctl, Terraform, IRSA, ALB, EBS storage
  
- **`aks/`** — [AKS (Azure)](./aks/)  
  Basic guide: Azure CLI, Terraform, managed identity
  
- **`gke/`** — [GKE (Google Cloud)](./gke/)  
  Basic guide: gcloud CLI, Terraform, Workload Identity

---

## 🔗 How This Connects to Module 09

After this module, your app is in the cloud. But **it's not secure yet**—any Pod can access any other Pod, default ServiceAccounts have too many permissions, etc.

**Module 09 (Security)** hardens the cluster: RBAC locks down who can do what, Network Policies block Pod-to-Pod traffic, Pod Security Admission prevents privilege escalation.

👉 **Next: [Module 09 — Security](../09-security/)**

---

## 🚀 Recommended Learning Path

1. **Start with EKS** if you want the most comprehensive guide (full Terraform, IRSA setup)
2. **Try AKS/GKE** if you want something simpler to get the gist
3. **Pick one for production** based on your company's cloud standardization

---

## ⚠️ Cost Warning

Cloud resources cost money. Estimate:

- **EKS Control Plane:** ~$0.10/hour = ~$75/month
- **Single t3.medium node:** ~$0.03/hour = ~$20/month per node
- **LoadBalancer:** ~$16/month
- **Storage:** Varies (10GB EBS ≈ $1/month)

**Total for minimal setup:** ~$130-200/month

**To avoid surprises:**
- Set a budget alert in your cloud console
- Delete clusters when not in use
- Use spot instances for non-critical workloads (70% discount)

---

## Next Steps

Choose your cloud and follow the guide in the corresponding subdirectory:

- **AWS?** → [EKS Guide](./eks/README.md)
- **Azure?** → [AKS Guide](./aks/README.md)
- **Google Cloud?** → [GKE Guide](./gke/README.md)
