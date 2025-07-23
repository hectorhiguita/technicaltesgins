# AMRIZE Technical Test - Complete CI/CD Infrastructure

This project demonstrates a complete AWS infrastructure deployment using Terraform with automated CI/CD pipeline that includes Docker image building, ECR deployment, and ECS container orchestration.

## 🏗️ Architecture Overview

### Infrastructure Components
- **VPC**: Custom VPC with public and private subnets using `for_each`
- **Subnets**: 2 public and 2 private subnets across different AZs
- **ECS Fargate**: Serverless container platform in private subnets
- **Application Load Balancer**: Public-facing load balancer
- **ECR**: Container registry for custom Docker images
- **NAT Gateway**: Internet access for private subnets
- **Security Groups**: Configured for web traffic
- **Remote State**: S3 backend with DynamoDB locking

### Security Architecture
```
Internet → ALB (Public Subnets) → ECS Fargate (Private Subnets) → Custom Docker App
                                    ↓
                              NAT Gateway (Outbound Access)
```

## 🚀 CI/CD Pipeline Features

The GitHub Actions pipeline (`/.github/workflows/terraform.yaml`) includes:

### 1. **Docker Build & Push**
- Builds custom Apache container with HTML content
- Tags with Git SHA and 'latest'
- Pushes to Amazon ECR automatically

### 2. **Infrastructure Deployment**
- Terraform validation and planning
- Automatic infrastructure provisioning
- PR comments with Terraform plans
- Dynamic image URI injection

### 3. **Service Updates**
- Forces ECS service redeployment
- Waits for service stability
- Zero-downtime deployments

### 4. **Deployment Verification**
- Health checks on deployed application
- Endpoint testing
- Deployment status reporting

## 📋 Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Docker (for local testing)
- GitHub repository with required secrets

## 🔧 GitHub Secrets Configuration

Set up the following secrets in your GitHub repository:

```
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
TF_STATE_BUCKET_NAME=your-terraform-state-bucket
TF_STATE_KEY_PREFIX=terraform-state
```

## 🛠️ Local Development

### Manual Deployment
1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Create terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit with your values
   ```

3. **Build and Deploy Docker Image:**
   ```bash
   ./deploy-to-ecr.sh
   ```

4. **Deploy Infrastructure:**
   ```bash
   terraform plan
   terraform apply
   ```

### Local Testing
```bash
# Build Docker image locally
docker build -t amrize-app .

# Run locally
docker run -p 8080:80 amrize-app

# Test
curl http://localhost:8080
```

## 🌐 Automated Deployment

### Push to Main Branch
Every push to `main` branch triggers:
1. Docker image build and ECR push
2. Infrastructure deployment with new image
3. ECS service update
4. Health verification

### Pull Request Process
Every PR shows:
1. Terraform plan preview
2. Infrastructure change summary
3. No actual deployment (plan only)

## 📁 Project Structure

```
├── .github/workflows/
│   └── terraform.yaml          # CI/CD Pipeline
├── Modules/
│   ├── VPC/                   # VPC with for_each subnets
│   ├── ECS/                   # Fargate cluster & services
│   ├── ECR/                   # Container registry
│   └── APP_Load_Balancer/     # Application load balancer
├── public-html/
│   └── index.html             # Custom web content
├── Dockerfile                 # Container definition
├── deploy-to-ecr.sh          # Local deployment script
├── main.tf                   # Root Terraform configuration
├── terraform.tfvars         # Variable values
└── README.md                # This file
```

## 🔄 Deployment Workflow

1. **Developer commits changes** to HTML or Dockerfile
2. **GitHub Actions triggers** automatically
3. **Docker image builds** with new content
4. **ECR receives** new tagged image
5. **Terraform updates** ECS task definition
6. **ECS deploys** new containers with zero downtime
7. **Health checks verify** successful deployment

## 📊 Monitoring & Outputs

After deployment, you'll have access to:
- **ALB URL**: Public endpoint for your application
- **ECR URI**: Container image location
- **ECS Cluster ARN**: Container cluster identifier
- **VPC ID**: Network infrastructure ID

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Or use GitHub Actions by deleting the branch
```

## 🔧 Troubleshooting

### Common Issues:
1. **ECR Push Fails**: Check AWS credentials and ECR repository exists
2. **ECS Tasks Don't Start**: Verify security groups and subnet routing
3. **ALB Unhealthy**: Check container port mapping and health check path

### Debug Commands:
```bash
# Check ECS service status
aws ecs describe-services --cluster amrize-ecs-cluster --services apache-service

# View container logs
aws logs tail /ecs/apache --follow

# Test ALB health
curl -I http://your-alb-url.amazonaws.com
```

## 🏆 Key Features Implemented

✅ **Infrastructure as Code** with Terraform modules
✅ **Containerized Application** with custom Docker image  
✅ **CI/CD Pipeline** with GitHub Actions
✅ **Zero-Downtime Deployments** with ECS rolling updates
✅ **Security Best Practices** with private subnets
✅ **Automated Testing** with health checks
✅ **State Management** with S3 backend
✅ **Resource Tagging** and organization

## Outputs

The module outputs VPC ID, subnet IDs, and other resource identifiers for use by other modules or external references. 
