output "public_ip" {
  value = aws_instance.monitoring.public_ip
}

output "private_ip" {
  value = aws_instance.monitoring.private_ip
}
