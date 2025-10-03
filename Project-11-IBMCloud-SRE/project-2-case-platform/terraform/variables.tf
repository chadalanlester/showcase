variable "region" {
  type    = string
  default = "us-west-2"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key_name" {
  type    = string
  default = "acme-key"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "The security group to associate with the instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "name" {
  description = "Name to tag the instance with"
  type        = string
}

variable "nginx_private_ip" {
  description = "Private IP address of the NGINX instance"
  type        = string
}
