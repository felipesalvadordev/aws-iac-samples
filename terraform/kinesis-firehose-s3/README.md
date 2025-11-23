# Kinesis Firehose S3 Data Pipeline

The project provisions a **serverless data streaming architecture** utilizing the following AWS services: **Kinesis Data Stream**, **Kinesis Data Firehose**, and **AWS Lambda**, with final data storage in **Amazon S3**.

This configuration is designed to:

  * **Ingest** high-volume, low-latency data (such as IoT sensor data).
  * **Apply business logic** (temperature transformation and humidity filtering).
  * **Persist** the processed results in a durable and structured manner.

**Purpose:** Ingestion, processing, and persistence of streaming data (e.g., IoT sensor data).

| AWS Component | Role in the Pipeline |
| :--- | :--- |
| **AWS Kinesis Data Stream** | Data ingestion point and buffer. Producers send records via `PutRecord`/`PutRecordBatch`. |
| **AWS Kinesis Data Firehose** | Orchestration service that moves and processes data. It reads records from Kinesis and inserts the result into the S3 bucket. |
| **AWS Lambda** | Data filtering and transformation logic. It processes/transforms the record (if applicable) and returns the result to Firehose. |
| **Amazon S3** | Final destination for storing processed data. |

Firehose and Lambda send operational logs to their respective **CloudWatch Log Groups** for monitoring. **IAM roles/policies** are configured to permit necessary actions (Kinesis read, S3 write, Lambda invoke, Logs write).

-----

## Prerequisites

1.  **AWS CLI Configured:** Your AWS credentials (Access Key and Secret Key) must be configured on your local machine, generally via `aws configure` or using environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).
2.  **Terraform:** Installed and ready for use.
3.  **Execution Environment:** Ensure your Lambda function code is packaged (the `data "archive_file"` block in `lambda.tf` handles this).

-----

## Deployment and Execution

### 1\. Terraform Initialization

Navigate to the project directory and initialize Terraform.

```bash
terraform init
```

### 2\. Planning and Application

Review the proposed changes and deploy the infrastructure.

```bash
terraform plan
terraform apply
```

### 3\. Data Flow Testing (AWS CLI)

Use the AWS CLI to send data to the Kinesis Stream and verify the pipeline.

#### A. Send Data to the Kinesis Stream:

```powershell
# Sends a single record
aws kinesis put-record `
  --cli-binary-format raw-in-base64-out `
  --stream-name ExampleDataStream `
  --data '{"device_id":"sensor-001","temperature":22.5,"humidity":60}' `
  --partition-key "sensor-001"

# Sends multiple records (batch)
aws kinesis put-records `
  --cli-binary-format raw-in-base64-out `
  --stream-name ExampleDataStream `
  --records `
    Data='{"device_id":"sensor-001","value":100}',PartitionKey=sensor-001 `
    Data='{"device_id":"sensor-002","value":200}',PartitionKey=sensor-002 `
    Data='{"device_id":"sensor-003","value":300}',PartitionKey=sensor-003
```

#### B. Wait for Data Flow and Verify S3

The Firehose batches and buffers records (the default is 60 seconds or when the buffer fills). Wait a moment, then check:

```powershell
# List objects in S3
aws s3 ls s3://bucket-for-iot-data-salvador/
```

### 4\. Check CloudWatch Logs

You can check the logs for Lambda execution and Firehose delivery status:

```powershell
# Lambda logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/firehose_lambda_processor_salvador

# Firehose logs
aws logs describe-log-groups --log-group-name-prefix /aws/kinesisfirehose/
```

### 5\. References
https://fullstackdojo.medium.com/streamlining-real-time-data-processing-with-aws-kinesis-lambda-and-terraform-36de21899d51