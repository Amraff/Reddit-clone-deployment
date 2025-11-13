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

## 5. Docker Build Failures
**Problem**: Docker build failed with missing environment variables and legacy ENV format
**Solutions**:
- Fixed ENV format from `ENV PORT 3000` to `ENV PORT=3000`
- Added ARG instructions to accept Firebase config as build arguments
- Updated GitHub Actions to pass Firebase secrets during Docker build

## 6. Resource Management Concerns
**Problem**: Worry about duplicate resource creation when pushing changes
**Solution**: Terraform manages resources idempotently - existing resources are detected and preserved
- S3 bucket creation uses `|| true` to prevent errors if exists
- Terraform state tracking prevents duplicates
- `terraform plan` shows changes before applying

## 7. Deployment Timeout Issues
**Problem**: Kubernetes deployment exceeded progress deadline - pods not starting within timeout
**Solutions**:
- Increased rollout timeout from default to 600 seconds
- Reduced resource requirements (memory: 128Mi, cpu: 100m)
- Extended health check delays (initialDelaySeconds: 60 for liveness, 30 for readiness)
- Changed to development mode to match Dockerfile CMD
- Added debugging steps to show pod status and logs on failure

## 8. JavaScript Heap Out of Memory
**Problem**: Pods crashing with "FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory"
**Solutions**:
- Increased memory requests from 128Mi to 512Mi
- Increased memory limits from 256Mi to 1Gi
- Added NODE_OPTIONS="--max-old-space-size=768" to increase heap size
- Changed NODE_ENV from development to production to reduce memory usage
- Eliminated Next.js non-standard NODE_ENV warning

## 9. HTTP 500 Internal Server Error - Blank Page
**Problem**: App returning HTTP 500 error and displaying blank page despite pods running
**Root Cause**: Missing Firebase environment variables in pods
**Solutions**:
- Added Firebase environment variables to GitHub Secrets
- Updated deployment.yml to reference GitHub Secrets
- Added sed commands in CI/CD to substitute secret values during deployment
- Verified environment variables are properly injected into pods

## 10. Environment Variable Management Issues
**Problem**: Firebase configuration not reaching application pods
**Solutions**:
- Store sensitive values in GitHub Secrets (encrypted)
- Use sed commands to substitute placeholders during deployment
- Add environment variables to both Docker build (ARG) and Kubernetes deployment (env)
- Verify variables are present in pods using kubectl exec

## Key Lessons
- Always use environment variables for sensitive data
- GitHub Actions workflows must be in `.github/workflows/` (plural)
- S3 backend buckets must exist before Terraform init
- Check AWS service version requirements for new features
- Docker builds need proper ARG/ENV handling for runtime variables
- Terraform safely handles existing resources without duplication
- Kubernetes deployments need adequate timeouts and resource allocation for startup
- Next.js applications require sufficient memory allocation (512Mi+ recommended)
- Missing environment variables cause HTTP 500 errors even when pods are running
- Use GitHub Secrets for secure environment variable management in CI/CD