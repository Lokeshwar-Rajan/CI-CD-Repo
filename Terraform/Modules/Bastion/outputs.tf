output "bastion_instance_id" {
  value       = aws_instance.bastion1.id
}

output "bastion_public_ip" {
  value       = aws_instance.bastion1.public_ip
}

output "bastion_private_ip" {
  value       = aws_instance.bastion1.private_ip
}
