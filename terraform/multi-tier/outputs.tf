output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "private_service_private_ip" {
  value = aws_instance.private_service.private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}