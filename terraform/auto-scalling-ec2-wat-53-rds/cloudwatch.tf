resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/app/main"
  retention_in_days = 1
}
