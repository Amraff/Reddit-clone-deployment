# Reddit Clone AWS Deployment Guide

This guide explains how to deploy the Reddit clone application to AWS using GitHub Actions, Terraform, and EKS.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **GitHub Repository** with the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **S3 Bucket** for Terraform state (update in `Eks-terraform/backend.tf`)

## Architecture

- **EKS Cluster**: Kubernetes cluster on AWS
- **ECR**: Container registry for Docker images
- **ALB**: Application Load Balancer for ingress
- **GitHub Actions**: CI/CD pipeline

## Setup Instructions

### 1. Configure GitHub Secrets

Add these secrets to your GitHub repository:
```
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

### 2. Update S3 Backend

Edit `Eks-terraform/backend.tf` with your S3 bucket name:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "EKS/terraform.tfstate"
    region = "us-west-2"
  }
}
```

### 3. Deploy Infrastructure

Push to main branch to trigger the GitHub Actions workflow:
```bash
git add .
git commit -m "Deploy to AWS"
git push origin main
```

### 4. Setup AWS Load Balancer Controller (One-time)

After EKS cluster is created, run:
```bash
chmod +x setup-alb-controller.sh
./setup-alb-controller.sh
```

### 5. Deploy Application with ALB Ingress

```bash
kubectl apply -f ingress-alb.yml
```

## GitHub Actions Workflow

The workflow (`github-workflows-deploy.yml`) performs:

1. **Terraform**: Creates/updates AWS infrastructure
2. **Build**: Creates Docker image and pushes to ECR
3. **Deploy**: Updates Kubernetes deployment with new image

## File Structure

```
├── Eks-terraform/          # Terraform configuration
├── deployment.yml          # Kubernetes deployment
├── service.yml            # Kubernetes service
├── ingress-alb.yml        # ALB Ingress configuration
├── github-workflows-deploy.yml  # GitHub Actions workflow
├── setup-alb-controller.sh # ALB controller setup script
└── Dockerfile             # Optimized production Dockerfile
```

## Accessing the Application

After deployment, get the load balancer URL:
```bash
kubectl get ingress reddit-clone-ingress
```

## Monitoring

Check deployment status:
```bash
kubectl get pods
kubectl get services
kubectl get ingress
```

## Cleanup

To destroy resources:
```bash
cd Eks-terraform
terraform destroy
```

## Troubleshooting

1. **ECR Push Issues**: Ensure AWS credentials have ECR permissions
2. **EKS Access**: Check IAM roles and RBAC configuration
3. **Load Balancer**: Verify ALB controller is installed and running

## Cost Optimization

- EKS cluster: ~$73/month
- EC2 instances: t3.medium ~$30/month each
- Load balancer: ~$16/month
- ECR storage: Minimal for small images