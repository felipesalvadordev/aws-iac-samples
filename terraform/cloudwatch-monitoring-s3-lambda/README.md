# CloudWatch Monitoring + S3 + Lambda (Image Processor)

This module provisions infrastructure for a Lambda image processor with monitoring (CloudWatch), S3 buckets, and SNS notifications.

## Key Components

- **S3**: upload and processed buckets
- **Lambda**: function that processes images (resizes, converts, generates variants)
- **CloudWatch**: logs, custom metrics, and dashboard
- **SNS**: topics/subscriptions for alerts

## Quick Deployment Guide

### Prepare Environment

For local testing, use LocalStack (docker-compose provided in this module). Example environment variables:

```powershell
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_REGION = "us-east-1"
$env:AWS_ENDPOINT = "http://localhost:4566"
```

### Step 1: Start LocalStack

```bash
docker-compose up -d
```

### Step 2: Create S3 Buckets Manually

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://image-processor-dev-upload-test
aws --endpoint-url=http://localhost:4566 s3 mb s3://image-processor-dev-processed-test
```

### Step 3: Deploy with Terraform

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 4: Test the Pipeline

```bash
# Get bucket name from Terraform output
UPLOAD_BUCKET=$(terraform output -raw upload_bucket_name)

# Upload an image
aws --endpoint-url=http://localhost:4566 s3 cp your-image.jpg s3://$UPLOAD_BUCKET/

# Watch logs in real-time
aws --endpoint-url=http://localhost:4566 logs tail $(terraform output -raw lambda_log_group_name) --follow
```

### Step 5: View Dashboard

```bash
terraform output cloudwatch_dashboard_url
# Open URL in browser (if dashboard is enabled in terraform.tfvars)
```

## Check Alarms

```bash
# List all alarms
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms --query 'MetricAlarms[].AlarmName'

# View alarm state
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms --alarm-names image-processor-dev-processor-high-error-rate

# Test alarm (trigger it)
aws --endpoint-url=http://localhost:4566 cloudwatch set-alarm-state \
  --alarm-name image-processor-dev-processor-high-error-rate \
  --state-value ALARM \
  --state-reason "Testing"
```

## Useful Commands

```bash
# View recent logs
aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/image-processor-dev-processor --since 1h

# List all Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# List all S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# View CloudWatch metrics
aws --endpoint-url=http://localhost:4566 cloudwatch list-metrics --namespace "ImageProcessor/Lambda"
```

## Documentation
- **Cost Estimates**: See [COST_ESTIMATE.md](COST_ESTIMATE.md) for AWS cost breakdown by scenario (dev, low production, high production)

## Tips for Development

- **Disable SNS in dev**: Set `alert_email = ""` to avoid costs
- **Use short log retention**: Set `log_retention_days = 3` in dev
- **LocalStack is free**: Use it for all local testing
- **Adjust resources**: Modify Lambda memory/timeout in `terraform.tfvars` for your use case

## Important Notes

- **S3 buckets must be created manually** (LocalStack S3 creation can hang)
- **Handler module name must be `lambda_function.py`** (avoid hyphens in module names)
- **All services must be enabled in LocalStack**: s3, lambda, iam, cloudwatch, sns, logs, sts
- **Use the managed docker-compose** provided to ensure all services are available

## Cleanup

```bash
# Destroy all resources
terraform destroy -auto-approve

# Stop LocalStack
docker-compose down
```
## Reference:  
https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/tree/3e556757f85bd39374da041c697f7c4e9c2d0448/lessons/day23/aws-lamda-monitoring


