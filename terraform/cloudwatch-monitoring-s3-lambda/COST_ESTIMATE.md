# AWS Cost Estimate — Image Processor

Cost reference for migrating from LocalStack to AWS real (US Region pricing, January 2026).

## Usage Scenarios

### Scenario 1: Development/Testing (100 uploads/month)

| Service | Usage | Cost/month | Note |
|---------|-------|-----------|------|
| **S3** | 100 objects × 2MB = 200MB | $0 | Within free tier (5GB) |
| **Lambda** | 100 invocations × 100ms | $0 | Within free tier (1M) |
| **CloudWatch** | 100 logs + 50 metrics | $0-5 | Logs: $0.50/GB; adjust retention |
| **SNS** | 50 messages | $0 | Within free tier |
| **Total** | | **~$0-5** | Virtually free |

### Scenario 2: Low Production (10k uploads/month)

| Service | Usage | Cost/month | Note |
|---------|-------|-----------|------|
| **S3** | 10k × 2MB = 20GB | $0.46 | $0.023/GB after 5GB free |
| **Lambda** | 10k invocations × 2s | $0.41 | $0.0000166667/100ms |
| **CloudWatch** | 10k logs + metrics | $5-10 | Logs: ~$0.50/GB; metrics: 50×$0.30 |
| **SNS** | 5k notifications | $2.50 | $0.50/1M msgs |
| **Total** | | **~$8-13** | |

### Scenario 3: High Production (100k uploads/month)

| Service | Usage | Cost/month | Note |
|---------|-------|-----------|------|
| **S3** | 100k × 2MB = 200GB | $4.60 | $0.023/GB |
| **Lambda** | 100k × 2s | $4.10 | |
| **CloudWatch** | 100k logs | $50 | Increases with volume; consider short retention |
| **SNS** | 50k notifications | $25 | $0.50/1M msgs |
| **Total** | | **~$84-100** | |

## AWS Free Tier (12 months)

- **S3**: 5GB storage + 20k GET + 2k PUT free/month
- **Lambda**: 1M requests + 3.2M seconds free/month
- **CloudWatch**: 10 log-in free; metrics charged
- **SNS**: 1k email notifications free/month
- **SNS**: 100k publish free/month

**Qualify for always-free tier** (no expiration date):
- Lambda: 1M requests/month (indefinite)
- CloudWatch Logs: 5GB ingestion/month (indefinite)

## Cost Reduction Tips

### 1. CloudWatch Logs
```hcl
# Reduce log retention in dev
log_retention_days = 3  # instead of 7

# In production, use 30 days
log_retention_days = 30
```

### 2. S3 Lifecycle Policies
```hcl
# Archive old objects to Glacier (90% cheaper)
# Example (add to s3_buckets module):
lifecycle_rule {
  enabled = true
  transition {
    days          = 30
    storage_class = "GLACIER"
  }
  expiration {
    days = 90
  }
}
```

### 3. Lambda
```hcl
# Reduce memory and timeout for test environments
lambda_memory_size = 512   # dev: 512MB
lambda_timeout     = 30    # dev: 30s

# Production: adjust as needed
lambda_memory_size = 1024  # prod
lambda_timeout     = 60    # prod
```

### 4. SNS
```hcl
# Disable SNS in development
enable_sns = false  # avoids notification costs

# Production: enable as needed
enable_sns = true
```

### 5. Monitoring
```bash
# Monitor costs daily in AWS Console
# AWS Billing → Cost Management → Cost Explorer

# Or via CLI:
aws ce get-cost-and-usage \
  --time-period Start=2026-01-01,End=2026-01-31 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

## Example: terraform.tfvars for Dev ($0 estimated costs)

```hcl
# Dev environment
aws_region              = "us-east-1"
project_name            = "image-processor"
environment             = "dev"
lambda_memory_size      = 512
lambda_timeout          = 30
log_retention_days      = 3
alert_email             = ""  # disables SNS
enable_cloudwatch_dashboard = false
```

## Example: terraform.tfvars for Prod (~$10-20/month expected)

```hcl
# Prod environment
aws_region              = "us-east-1"
project_name            = "image-processor"
environment             = "prod"
lambda_memory_size      = 1024
lambda_timeout          = 60
log_retention_days      = 30
alert_email             = "your-email@example.com"
enable_cloudwatch_dashboard = true
```

## Free Tier Estimator

Use the official AWS calculator:
https://calculator.aws/#/

Search for:
- Lambda
- S3
- CloudWatch
- SNS

## References

- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Pricing — S3](https://aws.amazon.com/s3/pricing/)
- [AWS Pricing — Lambda](https://aws.amazon.com/lambda/pricing/)
- [AWS Pricing — CloudWatch](https://aws.amazon.com/cloudwatch/pricing/)
- [AWS Pricing — SNS](https://aws.amazon.com/sns/pricing/)
- [Cost Explorer](https://console.aws.amazon.com/cost-management/)

---

**Final Tip:** For image processing applications (heavy processing), consider using:
- **AWS Batch** instead of Lambda (cheaper for long-running jobs)
- **CloudFront** + **S3** (global distribution and caching)
- **EventBridge** instead of SNS (more flexible, similar cost)
