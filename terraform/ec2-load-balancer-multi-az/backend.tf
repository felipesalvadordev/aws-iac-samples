terraform {
  backend "s3" {
    bucket = "tf-aws-architecture"
    key    = "path/to/statefile"
    region = "us-east-1"
  }
}
