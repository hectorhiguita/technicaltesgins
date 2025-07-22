# Technical Test - AWS Infrastructure with Terraform

This project demonstrates the deployment of AWS infrastructure using Terraform, including VPC, subnets, security groups, and state management.

## Architecture

- **VPC**: Custom VPC with public and private subnets
- **Subnets**: 2 public subnets and 2 private subnets across different AZs
- **NAT Gateway**: For private subnet internet access
- **Security Groups**: Configurable ingress rules
- **Remote State**: S3 backend with DynamoDB locking

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Access to AWS account with necessary permissions

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Create terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Plan the deployment:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **Destroy resources (when needed):**
   ```bash
   terraform destroy
   ```

## Configuration

See `terraform.tfvars.example` for required variables.

## Outputs

The module outputs VPC ID, subnet IDs, and other resource identifiers for use by other modules or external references. 
