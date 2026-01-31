resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "ec2-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro" # Free tier eligible
  user_data     = base64encode(templatefile("${path.module}/templates/user_data.tpl", {}))
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_autoscaling_group" "ec2_asg" {
  name                      = "ec2-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = "autoscaling-ec2"
    propagate_at_launch = true
  }
}