terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # LocalStack endpoint — descomente para usar LocalStack localmente
  # Comente ou remova para usar AWS real
  endpoints {
    s3         = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    logs       = "http://localhost:4566"
    sns        = "http://localhost:4566"
    iam        = "http://localhost:4566"
    sts        = "http://localhost:4566"
  }

  # Credenciais para LocalStack (dummy, apenas para testes)
  # Para AWS real, remova estas linhas e use credenciais reais
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
