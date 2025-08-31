variable "region" {
  type    = string
  default = "us-west-1"
}

variable "cluster_name" {
  type    = string
  default = "demo-eks"
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}
