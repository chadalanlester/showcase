variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "cluster_name" {
  type    = string
  default = "obs-ai-demo"
}

variable "grafana_admin_password" {
  type      = string
  default   = "ChangeMe123!"
  sensitive = true
}
