resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/firehose_lambda_processor_salvador"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name = "/aws/kinesisfirehose/terraform-kinesis-firehose-extended-s3-stream"
  retention_in_days = 1
}