# AWS EKS Terraform Jenkins CI/CD Project

This document serves as a guide for managing an AWS EKS Terraform Jenkins CI/CD infrastructure project. It covers the directory structure, deployment, connectivity, troubleshooting, and security best practices.

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
