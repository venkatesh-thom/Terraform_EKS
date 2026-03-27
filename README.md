# AWS EKS Terraform Jenkins CI/CD Project

This document serves as a guide for managing an AWS EKS Terraform Jenkins CI/CD infrastructure project. It covers the directory structure, deployment, connectivity, troubleshooting, and security best practices.

## Cluster Directory Structure

```
eks/
  ├── eks.yaml
  ├── terraform/
      ├── 00-vpc/
      ├── 10-subnets/
      ├── 20-route53/
      ├── 30-nat/
      ├── 40-ec2/
      ├── 50-eks/
      ├── 60-logging/
      ├── 70-monitoring/
      ├── 80-jenkins/
      ��── 90-eks/
```

### Terraform Modules
- **00-vpc**: Module for creating the VPC.
- **10-subnets**: Module for public/private subnets.
- **20-route53**: Module for DNS setup.
- **30-nat**: Module for NAT gateway configurations.
- **40-ec2**: Module for EC2 instances.
- **50-eks**: Module for EKS cluster.
- **60-logging**: Module for CloudWatch logging setup.
- **70-monitoring**: Module for monitoring setup (e.g., Prometheus).
- **80-jenkins**: Module for Jenkins setup.
- **90-eks**: Additional EKS configurations.

## Deployment Guide
1. Ensure that you have the necessary IAM permissions.
2. Clone the repository:
   ```
   git clone https://github.com/venkatesh-thomm/aws-eks-terraform-jenkins-cicd.git
   ```
3. Navigate to the directory:
   ```
   cd aws-eks-terraform-jenkins-cicd/eks/terraform/
   ```
4. Initialize Terraform:
   ```
   terraform init
   ```
5. Apply the Terraform configuration:
   ```
   terraform apply
   ```
6. Monitor the deployment.

## Cross-VPC Connectivity
- Utilize VPC peering to connect multiple VPCs.
- Configure security group rules to allow traffic between VPCs.

## Troubleshooting
- Verify the network configurations and security groups if connectivity issues arise.
- Check the EKS logs for any API requests that went wrong.
- Ensure IAM roles and policies are correctly configured.

## Security Best Practices
- Regularly update IAM policies to follow the principle of least privilege.
- Enable logging and monitoring services.
- Restrict SSH access to only trusted IP addresses.
- Use security groups to tightly control ingress and egress rules.

---
Document retrieved on 2026-03-27 13:07:10 UTC.