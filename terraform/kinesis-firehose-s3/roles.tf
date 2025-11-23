resource "aws_iam_role" "firehose_delivery_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "firehose.amazonaws.com",
        },
        Effect = "Allow",
        Sid = "",
      },
    ],
  })
}

resource "aws_iam_policy" "firehose_to_s3_policy" {
  name        = "firehose_to_s3_policy"
  description = "IAM policy for Firehose to write to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.iot_data_bucket_salvador.arn}",
          "${aws_s3_bucket.iot_data_bucket_salvador.arn}/*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards",
        ]
        Resource = "${aws_kinesis_stream.example_stream.arn}"
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_to_s3_attachment" {
  role       = aws_iam_role.firehose_delivery_role.name
  policy_arn = aws_iam_policy.firehose_to_s3_policy.arn
}


data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_firehose_logging_policy" {
  name        = "lambda_firehose_logging_policy"
  description = "IAM policy for Lambda and Firehose logging to CloudWatch Logs and access to Firehose"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch",
          "firehose:DescribeDeliveryStream",
          "firehose:ListDeliveryStreams",          
        ],
        // Specify the resource ARN for a more restrictive policy, or use a wildcard for broader access
        # Resource = "arn:aws:firehose:*:*:deliverystream/*"
        Resource="${aws_kinesis_firehose_delivery_stream.extended_s3_stream_salvador.arn}"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  role       = aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.lambda_firehose_logging_policy.arn
}



resource "aws_iam_policy" "firehose_logging_policy" {
  name        = "firehose_logging_policy"
  description = "IAM policy for Firehose CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
        ],
        Resource = [
          "${aws_cloudwatch_log_group.firehose_log_group.arn}:*",
        ],
        Effect = "Allow",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "firehose_logging_attachment" {
  role       = aws_iam_role.firehose_delivery_role.name
  policy_arn = aws_iam_policy.firehose_logging_policy.arn
}

resource "aws_iam_policy" "firehose_lambda_invocation_policy" {
  name        = "firehose_lambda_invocation_policy"
  description = "Allow Firehose to invoke Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
            "lambda:InvokeFunction",
            "lambda:GetFunctionConfiguration",
        ]
        Resource = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_lambda_invocation_attachment" {
  role       = aws_iam_role.firehose_delivery_role.name
  policy_arn = aws_iam_policy.firehose_lambda_invocation_policy.arn
}