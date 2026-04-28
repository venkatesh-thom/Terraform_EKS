
# AWS EKS Infrastructure via Terraform & Jenkins CI/CD

This repository provides a modular, production-ready approach to provisioning an **Amazon EKS (Elastic Kubernetes Service)** cluster along with its supporting networking and security infrastructure.

## 🚀 Overview

This project automates the creation of a full-stack AWS environment. It uses **Terraform** for Infrastructure as Code (IaC) and **Jenkins** for continuous integration and deployment.

### Key Components
* **VPC & Networking:** Custom VPC, subnets, and routing.
* **Security Groups:** Granular firewall rules for the cluster and bastion host.
* **Compute:** EKS Managed Node Groups and a dedicated Bastion/Workstation host.
* **Container Registry:** Amazon ECR for private Docker images.
* **Load Balancing:** Frontend ALB integrated with ACM for SSL/TLS.

---

## 📂 Project Structure

The project is broken down into numbered modules to ensure resources are created in the correct dependency order:

| Module | Description |
| :--- | :--- |
| `00-vpc` | Foundations: VPC, Public/Private Subnets, IGW, and NAT Gateway. |
| `10-sg` | Definition of Security Group resources. |
| `20-sg-rules` | Detailed Ingress/Egress rules for cross-component communication. |
| `30-bastion` | EC2 Workstation for administrative access and manual `kubectl` usage. |
| `40-ecr` | Private Elastic Container Registry for application images. |
| `65-acm` | Certificate management for secure HTTPS communication. |
| `70-frontend-alb` | Application Load Balancer setup for external traffic. |
| `90-eks` | The core EKS Cluster and Node Group configuration. |
| `cluster` (Optional) | Supplemental cluster-level configurations and YAML manifests. |

---

## 🛠 Deployment Options

You can deploy this infrastructure using two primary methods. 

> **Note:** The `cluster` folder is **optional** and primarily used for post-provisioning Kubernetes configurations.

### Option 1: Jenkins UI (Recommended)
This repo is optimized for CI/CD. 
1.  Connect this repository to your **Jenkins** instance.
2.  Ensure your Jenkins agent has the required **AWS Credentials** and **Terraform CLI** installed.
3.  Run the pipeline. Jenkins will parse the modules and apply the changes automatically.

### Option 2: Manual Terraform Execution
If you prefer to run the deployment from your local machine or the Bastion host:

1.  **Initialize:**
    ```bash
    terraform init
    ```
2.  **Plan:**
    ```bash
    terraform plan
    ```
3.  **Apply:**
    ```bash
    terraform apply --auto-approve
    ```

---

## 🔐 Security & Troubleshooting

* **Principle of Least Privilege:** Ensure the IAM role running Terraform has only the permissions necessary for the services listed above.
* **Connectivity:** If you cannot reach the EKS API, verify the Security Group rules in `20-sg-rules` and ensure your workstation IP is whitelisted.
* **State Management:** For production use, it is highly recommended to configure a remote S3 backend for your `terraform.tfstate` file.

---

## 🤝 Contributing
Feel free to open issues or submit pull requests to improve the modularity or security of this workflow.

---

### Tips for Customization:
* **Variable Overrides:** Check `variables.tf` in each module to customize region, instance types, or CIDR blocks.
* **Cleanup:** To tear down the infrastructure and avoid costs, run `terraform destroy`.

---

