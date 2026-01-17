# AWS Secrets Manager Secret Rotation with Lambda

This Terraform project automates the rotation of AWS Secrets Manager secrets using AWS Lambda on LocalStack.

## Overview

- **AWS Secrets Manager**: Securely store and manage secrets
- **Lambda Function**: Automatically rotates secrets on a schedule
- **IAM Role/Policy**: Grants Lambda permissions to access and rotate secrets

## Features

- Automatic secret rotation every 30 days (configurable)
- Lambda-based rotation logic
- CloudWatch monitoring support
- LocalStack compatible for local testing
- Infrastructure as Code (Terraform)

## Prerequisites

- Terraform >= 1.0
- AWS CLI v2
- Docker & Docker Compose
- Python 3.8+ (for Lambda function)

## Project Structure

```
rotating-secrets-with-aws-secrets/
├── main.tf              # Main Terraform configuration
├── provider.tf          # AWS provider configuration for LocalStack
├── docker-compose.yml   # LocalStack setup with secretsmanager service
├── lambda_rotation.py   # Lambda function for secret rotation
└── README.md            # This file
```

## Quick Start

### Step 1: Start LocalStack

```bash
docker-compose up -d
```

Wait for LocalStack to be ready (check health endpoint):

```bash
curl -s http://localhost:4566/_localstack/health | jq
```

### Step 2: Build Lambda Function Zip

Create the lambda_rotation.zip file:

**Linux/Mac:**
```bash
zip lambda_rotation.zip lambda_rotation.py
```

**Windows PowerShell:**
```powershell
Compress-Archive -Path lambda_rotation.py -DestinationPath lambda_rotation.zip
```

### Step 3: Deploy with Terraform

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply -auto-approve
```

### Step 4: Verify Deployment

```bash
# List secrets
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets

# Get secret value
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value \
  --secret-id sensitive-credentials
```

## Testing Commands

### Create Secret (Already created by Terraform)

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name test-secret \
  --secret-string '{"username":"test_user","password":"test_password"}'
```

### Retrieve Secret Value

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value \
  --secret-id sensitive-credentials
```

### Update Secret (Simulate Rotation)

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager put-secret-value \
  --secret-id sensitive-credentials \
  --secret-string '{"username":"rotated_user","password":"new_password_123"}'
```

### List Secret Versions

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager list-secret-version-ids \
  --secret-id sensitive-credentials
```

### Describe Secret Details

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager describe-secret \
  --secret-id sensitive-credentials
```

### List All Secrets

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets
```

### Delete Secret

```bash
aws --endpoint-url=http://localhost:4566 secretsmanager delete-secret \
  --secret-id sensitive-credentials \
  --force-delete-without-recovery
```

## Lambda Function Customization

The `lambda_rotation.py` file contains the secret rotation logic. This function:

1. Connects to Secrets Manager
2. Retrieves the current secret
3. Generates a new secret value
4. Updates the secret version
5. Updates version stage to CURRENT

### Customize Rotation Logic

Edit `lambda_rotation.py` to:
- Change password generation algorithm
- Update external systems (databases, APIs)
- Add custom validation logic
- Send notifications (SNS, email)

## Configuration

### Rotation Schedule

In `main.tf`, modify the rotation frequency:

```hcl
rotation_rules {
  automatically_after_days = 30  # Change to desired interval (7, 14, 30, 60, etc)
}
```

### IAM Permissions

The Lambda execution role automatically grants:
- `secretsmanager:GetSecretValue`
- `secretsmanager:PutSecretValue`
- `secretsmanager:UpdateSecretVersionStage`

Extend permissions in `main.tf` if needed for integration with other AWS services.

## Cost Estimation

| Service | Cost/Month |
|---------|-----------|
| Secrets Manager (1 secret) | $0.40 |
| API calls (~1/day) | ~$0.05 |
| Lambda execution | ~$0.01 |
| **Total** | **~$0.50** |

**LocalStack**: Free (local testing)

### Error: opening lambda_rotation.zip (no such file or directory)

**Solution**: Create the zip file before terraform apply:

```bash
# Linux/Mac
zip lambda_rotation.zip lambda_rotation.py

# Windows
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('.', 'lambda_rotation.zip')"
```

Check CloudWatch Logs:

```bash
aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/rotate-secret \
  --follow
```

## Cleanup

### Destroy Resources

```bash
# Remove Terraform infrastructure
terraform destroy -auto-approve
```

### Stop LocalStack

```bash
# Stop containers
docker-compose down

# Optional: Remove volumes (data loss)
docker-compose down -v
```

## Security Best Practices

✅ **Do's:**
- Use IAM roles instead of access keys
- Rotate secrets regularly (30-90 day intervals)
- Enable CloudTrail for audit logs
- Use VPC endpoints in production
- Restrict Lambda IAM permissions to minimum required

❌ **Don'ts:**
- Never commit secrets to version control
- Don't hardcode credentials in Lambda code
- Don't disable encryption
- Don't extend rotation intervals beyond 90 days
- Don't grant overly permissive IAM policies