# Auto-Scaling Private EC2 Instances

- Custom VPC with 2 public and 2 private subnets
- Security group in the public subnets that allows traffic from the internet and associate it with the Application Load Balancer, Internet Gateway and a NAT gateway
- Auto-Scaling Group of EC2 instances running Nginx service that allows traffic from the Application Load Balancer in the private subnets

![ec2-auto-scalling](https://github.com/user-attachments/assets/0560a737-3595-4f1e-8314-2615c58e1555)

https://medium.com/nerd-for-tech/auto-scaling-private-ec2-instances-with-terraform-9a7b5a079b72
