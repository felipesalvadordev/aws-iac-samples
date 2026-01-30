rds_conf = {
  instance_class          = "db.t3.micro"
  engine                  = "mysql"
  engine_version          = "8.0"
  allocated_storage       = 20
  storage_type            = "gp2"
  multi_az                = true
  username                = "admin"
  publicly_accessible     = false
  backup_retention_period = 7
}


env = "staging"