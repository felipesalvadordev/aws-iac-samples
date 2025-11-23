data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/index.js"
  output_path = "${path.module}/lambdas/lambda.zip"
}

resource "aws_lambda_function" "lambda_processor" {
  function_name = "firehose_lambda_processor_salvador"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_iam.arn
  runtime       = "nodejs16.x"
  timeout = 10
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}