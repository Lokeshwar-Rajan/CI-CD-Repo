resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.db_name}-rds-subnet-group"
  subnet_ids = var.subnet_ids
 
  tags = {
    Name = "${var.db_name}-rds-subnet-group"
  }
}
resource "aws_db_instance" "rds_postgres" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  identifier           = var.db_identifier
  monitoring_interval  = var.monitoring_interval
  monitoring_role_arn   = var.monitoring_role_arn
  db_name                = var.db_name
  vpc_security_group_ids = var.security_group_ids
  parameter_group_name   = var.parameter_group_name
  username               = var.db_username
  password              = var.db_password
  skip_final_snapshot = true
  multi_az               = true
  storage_encrypted      = true 
}