
# Cross-VPC Connectivity Troubleshooting Guide
## Runner EC2 (VPC-A) ➜ EKS Cluster Nodes (VPC-B)

This document provides a **step-by-step runbook** to troubleshoot **timeout issues** when a CI/CD runner EC2 in one VPC tries to reach EKS worker nodes in another VPC.
Both VPCs are in the **same region/AZ but use different CIDR blocks**.

---

## 1. Architecture Overview

- **VPC-A**: CI/CD Runner EC2
- **VPC-B**: EKS Cluster (Worker Nodes)
- **CIDRs**: Non-overlapping (mandatory)
- **Connectivity**: VPC Peering or Transit Gateway

> Same AZ does NOT mean automatic connectivity. Networking must be explicitly configured.

---

## 2. Identify the Exact Subnets

### Runner Side (VPC-A)
- Identify the subnet where the **runner EC2** is launched
- Note:
  - Subnet ID
  - Subnet CIDR
  - Associated Route Table

### Cluster Side (VPC-B)
- Identify **EKS worker node subnets**
- Ignore control-plane subnets (AWS-managed)
- Note:
  - Node group subnet IDs
  - Associated Route Tables

---

## 3. Verify VPC Connectivity

Ensure one of the following exists:
- VPC Peering Connection
- Transit Gateway attachment

If no connectivity exists, traffic will always timeout.

---

## 4. Route Table Configuration (CRITICAL)

### Runner Subnet Route Table (VPC-A)
Add route:
```
Destination: <VPC-B CIDR>
Target: pcx-xxxx OR tgw-xxxx
```

### EKS Node Subnet Route Table (VPC-B)
Add route:
```
Destination: <VPC-A CIDR>
Target: pcx-xxxx OR tgw-xxxx
```

> 
🚨 Real-world mistake:

Route added to main route table

Subnet uses a custom route table

→ Result: silent timeout

---

## 5. Security Group Rules (CIDR Based)

### Runner EC2 Security Group
Outbound rules:
- Destination: VPC-B CIDR
- Ports: 443, application ports, or required node ports

### EKS Node Security Group
Inbound rules:
- Source: VPC-A CIDR
- Ports: 443 / NodePort range / app ports

> Security group references do NOT work across VPCs. Use CIDR blocks only.

---

## 6. Network ACL Checks (Subnet Level)

For both runner and node subnets:

Inbound and Outbound must allow:
- Application ports
- Ephemeral ports: 1024–65535

Blocked ephemeral ports will cause TCP handshake failures.

---

## 7. Public vs Private Subnet Notes

### Runner Subnet
- Public or Private
- Private subnet requires NAT Gateway if:
  - Pulling images
  - Accessing public endpoints

### EKS Node Subnets
- Usually private
- NAT required for internet access (optional)

> Peering does not require NAT or IGW.

---

## 8. DNS Resolution

From runner EC2:
```
nslookup <node-or-service-dns>
```

If DNS fails:
- Enable DNS resolution in both VPCs
- Enable DNS resolution over VPC Peering
- For TGW, ensure Route53 Resolver rules exist

---

## 9. EKS-Specific Considerations

- Private API endpoint:
  - Runner must have routing + SG access
- NodePort access:
  - Allow NodePort range in node SG & NACL
- Internal Load Balancer:
  - ALB/NLB SG must allow runner CIDR

---

## 10. Connectivity Testing (From Runner EC2)

```
ping <node-private-ip>
telnet <node-private-ip> 443
curl https://<endpoint>
```

Results:
- Ping fails → Route/NACL issue
- Telnet fails → SG/NACL issue
- Curl fails → App/EKS/TLS issue

---

## 11. IAM Clarification

IAM does NOT affect packet flow.
Timeout issues are almost always **network-related**.

IAM is only required for:
- AWS API calls
- kubectl authentication

---

## 12. Flow Logs (Highly Recommended)

Enable VPC Flow Logs on:
- Runner subnet
- EKS node subnets

Look for:
- REJECT entries
- Missing return traffic

---

## 13. Final Sanity Checklist

- [ ] VPC Peering / TGW exists
- [ ] Correct subnets identified
- [ ] Routes added on BOTH sides
- [ ] No CIDR overlap
- [ ] Security groups allow CIDR-based traffic
- [ ] NACL allows ephemeral ports
- [ ] DNS resolution enabled
- [ ] Manual connectivity test successful

---

## 14. Key Takeaway

> VPCs may be connected, but **subnet route tables decide whether packets move**.

---

Author: DevOps Runbook  
Use this document as a production troubleshooting reference.
