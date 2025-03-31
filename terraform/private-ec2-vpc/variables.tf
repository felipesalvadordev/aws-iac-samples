#Variables
#VPC Variables

variable "aws_region" {
  description = "Region we deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "new_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

#EC2 Variables
variable "ami" {
  description = "ami of ec2 instance"
  type        = string
  default     = "ami-09cd747c78a9add63"
}

variable "instance_type" {
  description = "Size of EC2 Instances"
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = "boostrap script for nginx"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    
    # Update package repositories
    apt-get update -y
    
    # Install nginx
    apt-get install nginx -y
    
    # Start nginx service
    systemctl start nginx
    
    # Enable nginx to start on boot
    systemctl enable nginx
  EOF
}
