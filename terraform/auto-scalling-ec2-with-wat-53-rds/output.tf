output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.rds_master.endpoint
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}