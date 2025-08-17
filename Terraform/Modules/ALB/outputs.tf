output "alb_arn" {
  value       = aws_lb.us-lb.arn
}

output "alb_dns_name" {
  value       = aws_lb.us-lb.dns_name
}

output "alb_zone_id" {
  value       = aws_lb.us-lb.zone_id
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}
output "lb_listener_arn" {
  value = aws_lb_listener.http.arn
  
}