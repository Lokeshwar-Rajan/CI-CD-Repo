output "repository_url" {
  value       = aws_ecr_repository.foo.repository_url
}

output "repository_arn" {
  value       = aws_ecr_repository.foo.arn
}
output "ecr_repo_name" {
  value       = aws_ecr_repository.foo.name
  
}