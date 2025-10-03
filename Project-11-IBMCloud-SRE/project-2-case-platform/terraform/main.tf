terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  id = data.aws_subnets.default.ids[0]
}

module "key_pair" {
  source          = "./modules/key_pair"
  public_key_path = "~/.ssh/id_rsa.pub"
  key_name        = "acme-key"
}

module "security_group" {
  source = "./modules/security_group"
  name   = "allow_http_ssh"
  vpc_id = data.aws_vpc.default.id
}

module "ec2" {
  source             = "./modules/ec2"
  ami_id             = "ami-02de260c9d93d7b98"
  instance_type      = "t2.micro"
  key_name           = module.key_pair.key_name
  security_group_id  = module.security_group.id
  subnet_id          = data.aws_subnet.default.id
  name               = "acme-challenge"
}

module "monitoring" {
  source             = "./modules/monitoring"
  ami_id             = "ami-02de260c9d93d7b98"
  instance_type      = "t2.micro"
  key_name           = module.key_pair.key_name
  security_group_id  = module.security_group.id
  nginx_private_ip   = module.ec2.private_ip
}
