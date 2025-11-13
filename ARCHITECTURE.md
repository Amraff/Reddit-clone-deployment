# Reddit Clone AWS Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                GITHUB                                       │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │   Source Code   │───▶│ GitHub Actions  │───▶│      Secrets Store      │  │
│  │   (React/Next)  │    │    Workflow     │    │ (AWS Keys, Firebase)    │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS CLOUD (us-west-2)                              │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │       S3        │    │   Terraform     │    │         ECR             │  │
│  │ (State Backend) │◀───│   (IaC Tool)    │───▶│ (Container Registry)    │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────────────┘  │
│                                   │                         ▲               │
│                                   ▼                         │               │
│  ┌─────────────────────────────────────────────────────────┼─────────────┐  │
│  │                    VPC (Default VPC)                   │             │  │
│  │                                                         │             │  │
│  │  ┌─────────────────────────────────────────────────────┼─────────────┐  │  │
│  │  │              INTERNET GATEWAY                       │             │  │  │
│  │  └─────────────────────┬───────────────────────────────┼─────────────┘  │  │
│  │                        │                               │               │  │
│  │  ┌─────────────────────▼───────────────────────────────┼─────────────┐  │  │
│  │  │                 ROUTE TABLE                         │             │  │  │
│  │  └─────────────────────┬───────────────────────────────┼─────────────┘  │  │
│  │                        │                               │               │  │
│  │  ┌─────────────────────▼───────────────────────────────┼─────────────┐  │  │
│  │  │                PUBLIC SUBNETS                       │             │  │  │
│  │  │                                                     │             │  │  │
│  │  │ ┌─────────────────┐    ┌─────────────────┐          │             │  │  │
│  │  │ │   Subnet AZ-A   │    │   Subnet AZ-B   │          │             │  │  │
│  │  │ │                 │    │                 │          │             │  │  │
│  │  │ │ ┌─────────────┐ │    │ ┌─────────────┐ │          │             │  │  │
│  │  │ │ │ Node Group  │ │    │ │ Node Group  │ │          │             │  │  │
│  │  │ │ │(t3.medium)  │ │    │ │(t3.medium)  │ │          │             │  │  │
│  │  │ │ │             │ │    │ │             │ │          │             │  │  │
│  │  │ │ │┌─────────┐  │ │    │ │┌─────────┐  │ │          │             │  │  │
│  │  │ │ ││ Pod 1   │  │ │    │ ││ Pod 2   │  │ │          │             │  │  │
│  │  │ │ ││Reddit   │  │ │    │ ││Reddit   │  │ │          │             │  │  │
│  │  │ │ ││Clone    │  │ │    │ ││Clone    │  │ │          │             │  │  │
│  │  │ │ ││(Next.js)│  │ │    │ ││(Next.js)│  │ │          │             │  │  │
│  │  │ │ │└─────────┘  │ │    │ │└─────────┘  │ │          │             │  │  │
│  │  │ │ └─────────────┘ │    │ └─────────────┘ │          │             │  │  │
│  │  │ └─────────────────┘    └─────────────────┘          │             │  │  │
│  │  │           │                       │                 │             │  │  │
│  │  │           └───────────┬───────────┘                 │             │  │  │
│  │  │                       │                             │             │  │  │
│  │  │  ┌─────────────────────▼─────────────────┐          │             │  │  │
│  │  │  │         Kubernetes Service            │          │             │  │  │
│  │  │  │        (LoadBalancer Type)            │          │             │  │  │
│  │  │  └─────────────────────┬─────────────────┘          │             │  │  │
│  │  └──────────────────────────────────────────────────────┘             │  │  │
│  │                           │                                           │  │
│  │  ┌─────────────────────────▼─────────────────┐                        │  │
│  │  │         AWS Load Balancer                 │                        │  │
│  │  │    (Network Load Balancer)                │                        │  │
│  │  └─────────────────────┬───────────────────────┘                      │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            INTERNET                                         │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │     Users       │───▶│   Load Balancer │───▶│    Reddit Clone App     │  │
│  │   (Browsers)    │    │       URL       │    │  (Public Access)        │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL SERVICES                                 │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │                         FIREBASE                                        │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │  │
│  │  │ Authentication  │  │    Firestore    │  │       Storage           │  │  │
│  │  │    (Auth)       │  │   (Database)    │  │    (File Upload)        │  │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Architecture Components

### **CI/CD Pipeline**
- **GitHub Actions**: Automated deployment workflow
- **Terraform**: Infrastructure as Code (IaC)
- **Docker**: Container image building
- **ECR**: Container registry for storing images

### **AWS Infrastructure**
- **VPC**: Virtual Private Cloud (10.0.0.0/16)
- **Public Subnets**: 2 subnets across availability zones
- **Internet Gateway**: Provides internet access
- **Route Tables**: Routes traffic to internet gateway
- **EKS Cluster**: Managed Kubernetes service
- **EC2 Nodes**: t3.medium instances (2 nodes)
- **Load Balancer**: Network Load Balancer for public access
- **S3**: Terraform state backend storage

### **Application Layer**
- **Next.js App**: React-based Reddit clone
- **Kubernetes Pods**: 2 replicas for high availability
- **Service**: LoadBalancer type for external access

### **External Services**
- **Firebase**: Authentication, database, and storage
- **GitHub**: Source code and CI/CD

### **Data Flow**
1. Developer pushes code to GitHub
2. GitHub Actions triggers workflow
3. Terraform provisions/updates AWS infrastructure
4. Docker builds and pushes image to ECR
5. Kubernetes deploys pods with new image
6. Load Balancer routes traffic to healthy pods
7. Users access app via public URL