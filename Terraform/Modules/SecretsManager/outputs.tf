output "secret_arn" {
  value       = aws_secretsmanager_secret.secret.arn
}
 
output "secret_name" {
  value       = aws_secretsmanager_secret.secret.name
}

output "random_password" {
  value = random_password.db_pass.result
}