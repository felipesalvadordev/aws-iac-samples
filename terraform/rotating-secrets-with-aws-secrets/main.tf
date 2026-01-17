resource "aws_secretsmanager_secret" "credentials" {
  name        = "sensitive-credentials"
}

resource "aws_secretsmanager_secret_version" "example_version" {
  secret_id     = aws_secretsmanager_secret.credentials.id
  secret_string = jsonencode({
    username = "example_user"
    password = "example_password"
  })
}

resource "aws_iam_role" "lambda_rotation_role" {
  name = "lambda_rotation_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rotation_policy_attachment" {
  role       = aws_iam_role.lambda_rotation_role.name
  policy_arn = aws_iam_policy.lambda_rotation_policy.arn
}

resource "aws_iam_policy" "lambda_rotation_policy" {
  name   = "lambda_rotation_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [ aws_secretsmanager_secret.credentials.arn ]
      }
    ]
  })
}

resource "aws_lambda_function" "rotation_lambda" {
  filename         = "lambda_rotation.zip"  # Path to your zip file
  function_name    = "SecretRotationFunction"
  role             = aws_iam_role.lambda_rotation_role.arn
  handler          = "rotation.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_rotation.zip")

  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.credentials.arn
    }
  }
}

resource "aws_secretsmanager_secret_rotation" "example_rotation" {
  secret_id           = aws_secretsmanager_secret.credentials.id
  rotation_lambda_arn = aws_lambda_function.rotation_lambda.arn
  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotation_lambda.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.credentials.arn
}
