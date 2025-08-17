resource "aws_secretsmanager_secret" "secret" {
  name        = var.secret_name
  description = var.description
}
resource "random_password" "db_pass" {
  length  = 12
  special = true
}
resource "aws_secretsmanager_secret_version" "version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_pass.result
    endpoint = var.db_endpoint
    dbname   = var.db_name
  })
}


