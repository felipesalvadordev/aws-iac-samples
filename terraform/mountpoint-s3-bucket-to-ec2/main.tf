
//Create EC2
resource "aws_instance" "this" {
  ami                     = data.aws_ami.this.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = aws_iam_instance_profile.this.name
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.generated.key_name
  monitoring              = true
  subnet_id               = module.vpc.private_subnets[1]

  vpc_security_group_ids = [aws_security_group.this.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "required"
  }

  tags = merge(var.tags, {
    "Name"        = var.environment
    "backup"      = true
    "Patch Group" = "A"
  })

  volume_tags = merge(var.tags, { "Name" = "${var.environment}_vol" })

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  user_data = <<-EOF
      #!/bin/bash
      # Update packages on the system
      sudo yum update -y

      # Install S3 Mount
      wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
      sudo yum install ./mount-s3.rpm -y
      rm -f ./mount-s3.rpm

      # Create mount point directory
      sudo mkdir /mount_s3
      sudo mount-s3 ${module.s3.s3_bucket_id} /mount_s3
    EOF

  lifecycle {
    ignore_changes = [user_data, ami, vpc_security_group_ids]
  }
}

resource "aws_security_group" "this" {
  name        = var.environment
  description = "${var.environment} security group for owncloud"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "egress" {
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}
//Create S3
locals {
  mime_types = {
    txt = "text/plain"
  }
}

module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  force_destroy = true

  expected_bucket_owner = data.aws_caller_identity.this.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_object" "website-object" {
  bucket       = module.s3.s3_bucket_id
  for_each     = fileset("./files/", "**/*")
  key          = each.value
  source       = "./files/${each.value}"
  etag         = filemd5("./files/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

//Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.1"

  database_subnet_ipv6_prefixes                 = [6, 7, 8]
  enable_ipv6                                   = true
  private_subnet_ipv6_prefixes                  = [3, 4, 5]
  public_subnet_assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes                   = [0, 1, 2]

  azs                                             = local.availability_zones
  cidr                                            = local.vpc_cidr
  create_database_subnet_group                    = false
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  database_subnets                                = local.database_subnets
  enable_dhcp_options                             = true
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_flow_log                                 = true
  enable_nat_gateway                              = true
  flow_log_cloudwatch_log_group_retention_in_days = 7
  flow_log_max_aggregation_interval               = 60
  name                                            = var.environment
  one_nat_gateway_per_az                          = false
  private_subnet_suffix                           = "private"
  private_subnets                                 = local.private_subnets
  public_subnets                                  = local.public_subnets
  single_nat_gateway                              = true
  tags                                            = var.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.1.1"

  vpc_id = module.vpc.vpc_id
  tags   = var.tags

  endpoints = {
    s3 = {
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      service         = "s3"
      service_type    = "Gateway"
      tags            = { Name = "s3-vpc-endpoint" }
    }
  }
}

resource "random_string" "this" {
  length  = 4
  lower   = true
  numeric = true
  special = false
  upper   = false
}