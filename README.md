# AWS Samples
This repository contains AWS samples that i´ve created for my own learning.  
Samples will be indepentent of programming languages.  
All will be create with Infrastructure As Code tools such as Terraform. 

## List of projects:  
[Dynamic EC2 Scaling with SQS Backlog](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/auto-scaling-ec2-policy-based-on-sqs)  
[Auto Scaling EC2 with WAF, Route 53 and Relational Database](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/auto-scaling-ec2-waf-53-rds)  
[Auto Scaling private EC2](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/auto-scalling-private-ec2)  
[Deploy with Fargate ECS](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/fargate-ecs)  
[Data Streaming with Kinesis, Lambda, Firehose and S3](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/kinesis-firehose-s3)  
[Mount an AWS S3 bucket into an EC2](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/mountpoint-s3-bucket-to-ec2)  
[VPC Peering Connection between two VPCs in same region](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/vpc-peering)  
[CloudWatch Monitoring + S3 + Lambda (Image Processor)](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/cloudwatch-monitoring-s3-lambda)  
[Secrets Manager Secret Rotation with Lambda](https://github.com/felipesalvadordev/aws-iac-samples/tree/main/terraform/rotating-secrets-with-aws-secrets)

## Implementations

### Compute & Orchestration

* **Serverless & Containers:** Deployed containerized applications using **AWS Fargate** and **Amazon ECS**, focusing on high scalability without server management overhead.
* **Message-Driven Scaling:** Implemented **EC2 Auto Scaling** policies triggered by **Amazon SQS** backlog metrics, optimizing asynchronous processing and operational costs.

### Security & Governance

* **Network Architecture:** Designed **VPCs** featuring public/private subnet segmentation, **NAT Gateways**, and secure routing.
* **Access Control:** Enforced the **Principle of Least Privilege (PoLP)** via granular **IAM policies** and restrictive **Security Groups**.
* **Framework Compliance:** Built architectures strictly following the **AWS Well-Architected Framework** best practices.

### Data & Streaming

* **Real-time Streaming:** Configured high-throughput data ingestion pipelines using **Amazon Kinesis**.
* **Storage & Databases:** Managed **Amazon S3** buckets with automated Lifecycle Policies and handled **Amazon RDS** database instance provisioning.

### Automation & CI/CD

* **Automated Pipelines:** Built CI/CD workflows using **GitHub Actions** for automated testing, validation, and resource provisioning.

