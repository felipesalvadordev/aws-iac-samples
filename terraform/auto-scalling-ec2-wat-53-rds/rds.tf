resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "rds_master" {
  identifier              = "rds-master"
  allocated_storage       =  var.rds_conf.allocated_storage
  engine                  = var.rds_conf.engine
  engine_version          = var.rds_conf.engine_version
  instance_class          = var.rds_conf.instance_class
  username                = var.rds_conf.username
  password                = aws_ssm_parameter.db_password.value
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = var.rds_conf.publicly_accessible
  multi_az                = var.rds_conf.multi_az
  backup_retention_period = var.rds_conf.backup_retention_period
}

resource "random_password" "root_password" {
  length      = 8
  special     = false
  min_numeric = 5
}

resource "aws_ssm_parameter" "db_password" {
  name   = "/rds/${var.env}-rds/password"
  value  = var.rds_conf.multi_az == true ? random_password.root_password.result : "test"
  type   = "SecureString"
  key_id = "alias/aws/ssm"
}

