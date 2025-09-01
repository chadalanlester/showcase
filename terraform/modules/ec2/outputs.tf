output "public_ip" {
  value = aws_instance.nginx.public_ip
}

output "private_ip" {
  value = aws_instance.nginx.private_ip
}
