# Simple Architecture Diagram

```
Developer → GitHub → AWS → Users

┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ You     │───▶│ GitHub  │───▶│   AWS   │───▶│ Users   │
│ (Code)  │    │Actions  │    │   EKS   │    │Browser  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

## What Each Part Does:

**You (Developer)**
- Write code
- Push to GitHub

**GitHub Actions**
- Builds Docker image
- Deploys to AWS
- Runs automatically

**AWS EKS**
- Runs your app
- Provides public URL
- Handles traffic

**Users**
- Access your app
- Use Reddit clone features

## Your App URL:
```
http://a77e2a5ec26864ad1b57d89bce1245f3-8de3d6faa1c2be28.elb.us-west-2.amazonaws.com
```