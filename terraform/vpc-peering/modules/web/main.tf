####################################################
# Get latest Amazon Linux 2 AMI
####################################################
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

####################################################
# Create the security group for EC2
####################################################
resource "aws_security_group" "security_group" {
  description = "Allow traffic for EC2"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Allow all incoming ICMP"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-sg-ec2"
  })
}

####################################################
# Create the Linux EC2 instance with a website
####################################################
resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = var.instance_key
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.security_group.id]

  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd.x86_64
  systemctl start httpd.service
  systemctl enable httpd.service
  instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
  instanceAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
  pubHostName=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
  pubIPv4=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
  privHostName=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
  privIPv4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  
  echo "<font face = "Verdana" size = "5">"                               > /var/www/html/index.html
  echo "<center><h1>AWS Linux VM Deployed with Terraform</h1></center>"   >> /var/www/html/index.html
  echo "<center> <b>EC2 Instance Metadata</b> </center>"                  >> /var/www/html/index.html
  echo "<center> <b>Instance ID:</b> $instanceId </center>"                      >> /var/www/html/index.html
  echo "<center> <b>AWS Availablity Zone:</b> $instanceAZ </center>"             >> /var/www/html/index.html
  echo "<center> <b>Public Hostname:</b> $pubHostName </center>"                 >> /var/www/html/index.html
  echo "<center> <b>Public IPv4:</b> $pubIPv4 </center>"                         >> /var/www/html/index.html
  echo "<center> <b>Private Hostname:</b> $privHostName </center>"               >> /var/www/html/index.html
  echo "<center> <b>Private IPv4:</b> $privIPv4 </center>"                       >> /var/www/html/index.html
  echo "</font>"                                                          >> /var/www/html/index.html
EOF

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ec2-${var.ec2_name}"
  })
}