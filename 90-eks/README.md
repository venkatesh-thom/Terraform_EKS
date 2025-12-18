# README – EKS Blue-Green Upgrade with Terraform & Scripts

This document explains how to upgrade an EKS cluster control plane and nodegroups using **Blue-Green deployment strategy** with Terraform automation + shell upgrade scripts.

---

## ✔️ Environment Details

| Component | Value |
|---------|------|
| Cluster Name | `roboshop-dev` |
| AWS Region | `us-east-1` |
| Current Control Plane Version | `1.32` |
| Target Control Plane Version | `1.33` |
| Running NodeGroup | `blue` |
| New NodeGroup will be | `green` |

---

## ✔️ Terraform Apply Input Example

```sh
terraform apply -auto-approve
```

Values entered:

```
var.eks_nodegroup_blue_version    = 1.32
var.eks_nodegroup_green_version   = 1.32
var.eks_version                   = 1.32
var.enable_blue                   = true
var.enable_green                  = false
```

---

## ✔️ kubeconfig update (post terraform cp upgrade)

```sh
aws eks update-kubeconfig --region us-east-1 --name roboshop-dev
```

---

## ✔️ Pre-Upgrade State

```
EKS version: 1.32
Running nodegroup: blue
Nodegroup version: 1.32
```

Target state:

```
EKS target version: 1.33
Target nodegroup: green
Target nodegroup version: 1.33
```

---

## Cluster Upgrdae 

 - ## Manually :
   # 🔵 CONTROL PLANE + ADDONS UPGRADE PROCESS
   # 🟢 NODEGROUP UPGRADE STRATEGY (BLUE → GREEN)
   

# 🔵 CONTROL PLANE + ADDONS UPGRADE PROCESS

## Step 1 – Validate parameters

- If no input version → exit script
- If version gap > 1 minor → exit

Example check:

```
1.32 → 1.33 ✔ Allowed
1.32 → 1.34 ❌ Reject
```

---

## Step 2 – Retrieve current EKS version

```
aws eks describe-cluster --name roboshop-dev   --query "cluster.version" --output text
```

---

## Step 3 – Start EKS control plane upgrade

```
terraform apply -auto-approve
```

Wait until:

- status becomes ACTIVE
- version matches target

Cluster check loop:

```
while [[ $(aws eks describe...) != "ACTIVE" ]]
do
 sleep 60
done
```

---

## Step 4 – Addons Upgrade Logic

### Steps inside script:

1. Fetch installed addons
2. For each addon:
   - get current version
   - get latest compatible version
3. if equal → skip
4. if newer exists → upgrade

Example:

```
aws eks list-addons
aws eks describe-addon-versions
aws eks update-addon
```

---

# 🟢 NODEGROUP UPGRADE STRATEGY (BLUE → GREEN)

---

## Step 1 – Detect running group

```
if blue = running
   target = green
else
   target = blue
```

---

## Step 2 – get kubelet version of existing nodes

```sh
kubectl get nodes -l "nodegroup=blue"   -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}'
```

Expected result:

```
v1.32.x
```

---

## Step 3 – Create GREEN nodegroup (new version)

Terraform logic:

```
create_blue = true,  version=1.32
create_green = true, version=1.33
```

---

## Step 4 – verify green readiness

```sh
kubectl get nodes -l nodegroup=green
```

Expected:

```
all nodes = Ready
```

---

## Step 5 – cordon blue nodes

```sh
kubectl cordon node01
```

---

## Step 6 – drain blue nodes

```sh
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data
```

Workloads shift to green.

---

## Step 7 – remove blue nodegroup

Terraform logic:

```
create_blue=false, version=1.32
create_green=true,  version=1.33
```

Apply → blue removed completely.

---

# ✔ Script Example Calls

Upgrade control plane:

```sh
sh upgrade-cluster.sh 1.34
```

Upgrade nodegroup:

```sh
sh upgrade-nodegroup.sh green
```

---

# Expected Final Output State

| Item | Value |
|---|---|
| Control Plane | 1.33 |
| Nodegroup | Green only |
| Blue | Deleted |
| Addons | Updated |
| Kubelets | 1.33 |

---

# Rollback Logic

- If green fails → delete green → keep blue
- No downtime
- Immediate revert possible

---

# Advantages of Blue-Green Nodegroups

- Zero downtime upgrade
- Reduces risk
- Workload auto migration
- Rollback ready

---

# Next version upgrade example

```sh
sh upgrade-cluster.sh 1.34
sh upgrade-nodegroup.sh green
```
