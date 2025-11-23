terraform {
  backend "local" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_kinesis_stream" "example_stream" {
  name             = "ExampleDataStream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_s3_bucket" "iot_data_bucket_salvador" {
  bucket = "bucket-for-iot-data-salvador"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.iot_data_bucket_salvador.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream_salvador" {
  name        = "final-stream-processor-v1"
  destination = "extended_s3"
kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.example_stream.arn
    role_arn           = aws_iam_role.firehose_delivery_role.arn
  }
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_delivery_role.arn
    bucket_arn = aws_s3_bucket.iot_data_bucket_salvador.arn
    
    cloudwatch_logging_options {
      enabled       = true
      log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
      log_stream_name = "FirehoseDelivery"
    }
    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = aws_lambda_function.lambda_processor.arn
        }
      }
    }
  }
}