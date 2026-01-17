output "function_name" {
  description = "Name of the Lambda function"
  value       = var.use_image ? aws_lambda_function.function_image[0].function_name : aws_lambda_function.function_zip[0].function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = var.use_image ? aws_lambda_function.function_image[0].arn : aws_lambda_function.function_zip[0].arn
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = var.use_image ? aws_lambda_function.function_image[0].invoke_arn : aws_lambda_function.function_zip[0].invoke_arn
}

output "function_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "function_role_name" {
  description = "Name of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.arn
}
