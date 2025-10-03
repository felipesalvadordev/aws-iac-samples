# variables.tf

variable "aws_access_key" {
    description = "The IAM public access key"
}

variable "aws_secret_key" {
    description = "IAM secret access key"
}

variable "aws_region" {
    description = "The AWS region things are created in"
}

variable "ec2_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
    description = "ECS auto scale role name"
    default = "myEcsAutoScaleRole"
}

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = "1" # Keep at 1 for testing, increase for production
}

variable "app_image" {
    description = "Docker image to run in the ECS cluster"
    default = "centos:8"
}

variable "app_port" {
    description = "Port exposed by the docker image to redirect traffic to"
    default = 3000

}

variable "app_count" {
    description = "Number of docker containers to run"
    default = 1 # Keep at 1 for testing, increase for production
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
    description = "CPU allocated to each Fargate task (in vCPU units)"
    default = "256"
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "512"
}