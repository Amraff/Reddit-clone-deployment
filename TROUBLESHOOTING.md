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

## 11. Sed Command Syntax Error - Invalid Back Reference
**Problem**: `sed: -e expression #1, char 30: Invalid back reference` when trying to substitute GitHub Secrets syntax
**Root Cause**: GitHub Actions syntax `${{ secrets.NAME }}` contains special characters that break sed regex
**Solutions**:
- Replaced GitHub Secrets syntax with simple placeholders in deployment.yml
- Updated sed commands to use simple string replacement instead of complex regex
- Used format: `sed -i "s|PLACEHOLDER|${{ secrets.VALUE }}|g"`

## 12. React JSX Runtime Error - HTTP 500
**Problem**: `(0 , react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV) is not a function`
**Root Cause**: NODE_ENV mismatch - running `npm run dev` (development) with `NODE_ENV=production`
**Solutions**:
- Changed NODE_ENV from "production" to "development" to match npm command
- Ensured consistency between Docker CMD and environment variables
- Fixed JSX runtime compatibility issues

## 13. kubectl Command Syntax Errors
**Problem**: `error: unknown shorthand flag: 'l' in -l` when using kubectl exec
**Solutions**:
- Fixed kubectl exec syntax: `kubectl exec $POD_NAME -- command` instead of `kubectl exec -l`
- Used pod name selection: `POD_NAME=$(kubectl get pods -l app=reddit-clone -o jsonpath='{.items[0].metadata.name}')`
- Added proper error handling for missing executables in containers

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
- Avoid special characters in sed regex patterns - use simple string replacement
- Match NODE_ENV with the actual npm command being executed
- Use proper kubectl syntax for pod selection and command execution