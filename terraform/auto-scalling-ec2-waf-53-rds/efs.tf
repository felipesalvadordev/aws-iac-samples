resource "aws_efs_file_system" "efs" {
  creation_token = "main-efs"
  tags = { Name = "main-efs" }
}

resource "aws_efs_mount_target" "efs_a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_a.id
  security_groups = [aws_security_group.ec2_sg.id]
}

resource "aws_efs_mount_target" "efs_b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.ec2_sg.id]
}