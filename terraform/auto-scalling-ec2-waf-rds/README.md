# Auto-Scaling EC2 with WAF, RDS, EFS, and Route53 (Terraform)

This project provisions a scalable and secure AWS infrastructure using Terraform. It includes EC2 Auto Scaling, WAF protection, RDS database, EFS storage, Route53 DNS, and all necessary networking components.

## Architecture Overview

![Architecture](docs/architecture.jpg)

## Project Workflow
1. Front End Request
A user or client sends a request to the application’s front end.

2. DNS Resolution via Route 53
The request first goes to AWS Route 53, which handles DNS resolution and directs traffic to the correct endpoint.

3. SSL/TLS Termination via AWS Certificate Manager
AWS Certificate Manager provides SSL/TLS certificates for secure communication between the client and the application.

4. Traffic Filtering via AWS WAF
AWS Web Application Firewall (WAF) inspects incoming requests for security threats and filters malicious traffic.

5. Load Balancing and Auto Scaling
The Application Load Balancer distributes incoming requests across multiple EC2 instances in different Availability Zones (A and B).
Auto Scaling ensures that the number of EC2 instances adjusts automatically based on demand.

6. Shared Storage via AWS EFS
EC2 instances access shared storage using Amazon Elastic File System (EFS), allowing them to read/write files as needed.

7. Database Access via Amazon RDS
EC2 instances connect to Amazon RDS for database operations.
RDS is configured with a master and a replica for high availability and failover.

8. Monitoring via AWS CloudWatch
AWS CloudWatch collects logs and metrics from the infrastructure for monitoring and alerting.

9. CI/CD Pipeline Initiation
Developers push code changes to GitHub.

10. Infrastructure Automation via GitHub Actions & Terraform

GitHub Actions triggers Terraform workflows to plan and apply infrastructure changes automatically, updating the AWS environment as needed.

Other Components:
Security Groups: Control inbound and outbound traffic to EC2 instances.
KMS (Key Management Service): Manages encryption keys for securing data.

## Resources Created

- **VPC & Networking**
  - VPC
  - Subnets (public/private)
  - Internet Gateway
  - NAT Gateway
  - Route Tables

- **Compute**
  - EC2 Auto Scaling Group
  - Launch Template with custom user data (`templates/user_data.tpl`)
  - Security Groups

- **Storage**
  - Amazon EFS (Elastic File System)

- **Database**
  - Amazon RDS (Relational Database Service)

- **Security**
  - AWS WAF (Web Application Firewall)

- **DNS**
  - Amazon Route 53 (Hosted Zone and DNS records)

## Files

- `vpc.tf` — VPC and networking resources
- `autoscaling.tf` — EC2 Auto Scaling Group and Launch Template
- `efs.tf` — EFS resources
- `rds.tf` — RDS resources
- `waf.tf` — WAF configuration
- `route_53.tf` — Route53 DNS setup
- `provider.tf` — AWS provider configuration
- `local.tf` — Local values
- `variables.tf` — Input variables
- `output.tf` — Output values
- `templates/user_data.tpl` — EC2 instance bootstrap script
- `staging.terraform.tfvars` — Example variable values for staging

## How to Execute

1. **Configure AWS Credentials**
   - Ensure your AWS credentials are set in your environment (e.g., via `aws configure` or environment variables).

2. **Initialize Terraform**
   ```sh
   terraform init
   ```

3. **Review the Plan**
   ```sh
   terraform plan -var-file=staging.terraform.tfvars
   ```

4. **Apply the Configuration**
   ```sh
   terraform apply -var-file=staging.terraform.tfvars
   ```

5. **Check Outputs**
   - After apply, Terraform will show useful outputs such as DNS names, EFS IDs, RDS endpoints, etc.

## Customization

- Edit `variables.tf` and `staging.terraform.tfvars` to customize instance types, database settings, domain names, and other parameters.
- Modify `templates/user_data.tpl` for custom EC2 bootstrapping.
