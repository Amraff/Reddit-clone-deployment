# Deployment Issues Encountered & Solutions

## 1. Security Alert - Exposed Firebase API Keys
**Problem**: GitHub detected hardcoded Firebase API keys in source code
**Solution**: Moved Firebase config to environment variables using `process.env.NEXT_PUBLIC_*`

## 2. GitHub Actions Pipeline Not Triggering
**Problem**: Workflow file in wrong location and branch mismatch
**Solutions**: 
- Moved workflow from root to `.github/workflows/` directory (not `.github/workflow/`)
- Fixed branch references from `main` to `master` throughout workflow

## 3. S3 Backend Bucket Missing
**Problem**: Terraform state bucket `rafftec-backend-bucket112025` didn't exist
**Solution**: Added S3 bucket creation step in GitHub Actions before `terraform init`

## 4. EKS Version Compatibility
**Problem**: EKS Auto Mode requires cluster version 1.29+, but config had 1.28
**Solution**: Updated EKS cluster version from 1.28 to 1.29 in Terraform configuration

## Key Lessons
- Always use environment variables for sensitive data
- GitHub Actions workflows must be in `.github/workflows/` (plural)
- S3 backend buckets must exist before Terraform init
- Check AWS service version requirements for new features