output "db_instance_address" {
  value       = aws_db_instance.rds_postgres.address
}
output "db_instance_port" {
  value       = aws_db_instance.rds_postgres.port
}
output "db_instance_arn" {
  value       = aws_db_instance.rds_postgres.arn
}
output "db_endpoint" {
  value = aws_db_instance.rds_postgres.endpoint
}
