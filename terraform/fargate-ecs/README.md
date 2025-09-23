# Fargate-ECS

### Project Summary
This project demonstrates a complete application stack on Amazon Web Services using Amazon ECS (Elastic Container Service) with the Fargate launch type. It showcases an Infrastructure-as-Code (IaC) approach to automatically deploy a scalable and resilient application with a single command.

### Key Features
Infrastructure-as-Code (IaC): The entire application stack is defined in Terraform configuration files for automated and repeatable deployments.

Containerization: The application is containerized and deployed on Amazon ECS, abstracting away the underlying server management.

Serverless Compute: AWS Fargate is used to run containers without the need to provision, configure, or scale EC2 instances, minimizing operational overhead.

High Availability: The architecture is designed to be highly available, running instances across multiple subnets within a Virtual Private Cloud (VPC).

Scalability: An Auto Scaling Group is configured to automatically adjust the number of running containers based on demand.

Load Balancing: An Application Load Balancer (ALB) distributes incoming traffic to the container instances, ensuring consistent performance.

Security: The setup includes configured Security Groups to control network access between different components.

Logging: The architecture integrates with Amazon CloudWatch for centralized logging, providing observability into the application's performance.  

References: https://medium.com/@olayinkasamuel44/using-terraform-and-fargate-to-create-amazons-ecs-e3308c1b9166
