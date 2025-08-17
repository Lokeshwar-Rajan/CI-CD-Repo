output "ecs_cluster_id" {
  value       = aws_ecs_cluster.myecs.id
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.myecs.name
}

output "asg_name" {
  value       = aws_autoscaling_group.ecs_asg.name
}

output "frontend_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend.name
}

