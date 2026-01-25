provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "vpc-teste-scaling" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Its true to avoid NAT Gateway
  availability_zone       = "us-east-1a"
  tags                    = { Name = "subnet-teste-scaling" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# --- SQS QUEUE ---
resource "aws_sqs_queue" "app_queue" {
  name                      = "app-processing-queue"
  delay_seconds             = 0
  message_retention_seconds = 3600
}

# --- IAM roles and Permissions ---
resource "aws_iam_role" "ec2_sqs_role" {
  name = "ec2-sqs-processor-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "sqs_policy" {
  name = "sqs-processor-policy"
  role = aws_iam_role.ec2_sqs_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
      Effect   = "Allow",
      Resource = aws_sqs_queue.app_queue.arn
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-sqs-instance-profile"
  role = aws_iam_role.ec2_sqs_role.name
}

# --- AUTO SCALING ---
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = "ami-0c101f26f147fa7fd" # Amazon Linux 2
  instance_type = "t2.micro"             

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.public.id
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg"
  desired_capacity    = 0
  max_size            = 2 
  min_size            = 0
  vpc_zone_identifier = [aws_subnet.public.id]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}

# --- Scaling Policy---

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_queue" {
  alarm_name          = "high-sqs-backlog"
  comparison_operator = "GreaterThanThreshold" 
  evaluation_periods  = "1" 
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS" 
  period              = "60" 
  statistic           = "Average" 
  threshold           = "10" 
  dimensions          = { QueueName = aws_sqs_queue.app_queue.name } 
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn] 
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "low_queue" {
  alarm_name          = "low-sqs-backlog" 
  comparison_operator = "LessThanOrEqualToThreshold" 
  evaluation_periods  = "1" 
  metric_name         = "ApproximateNumberOfMessagesVisible" 
  namespace           = "AWS/SQS" 
  period              = "60"
  statistic           = "Average" 
  threshold           = "0" 
  dimensions          = { QueueName = aws_sqs_queue.app_queue.name }
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn] 
}