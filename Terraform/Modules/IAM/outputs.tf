output "role_arn" {
  value = aws_iam_role.this.arn
}
output "instance_profile_name" {
  value       = try(aws_iam_instance_profile.this[0].name, null)
  description = "Instance profile name if created, else null"
}
