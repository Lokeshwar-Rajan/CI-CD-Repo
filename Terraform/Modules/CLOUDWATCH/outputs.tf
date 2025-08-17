output "ecs_frontend_log_group_name" {
  value       = aws_cloudwatch_log_group.ecs_frontend.name
}

output "ecs_backend_log_group_name" {
  value       = aws_cloudwatch_log_group.ecs_backend.name
}

