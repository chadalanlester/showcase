output "nginx_public_ip" {
  description = "Public IP of the NGINX EC2 instance"
  value       = module.ec2.public_ip
}

output "monitoring_public_ip" {
  description = "Public IP of the Monitoring EC2 instance"
  value       = module.monitoring.public_ip
}
