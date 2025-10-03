variable "ibmcloud_api_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-south"
}

variable "resource_group" {
  type    = string
  default = "Default"
}

variable "icr_region" {
  type    = string
  default = "us"
}

variable "icr_namespace" {
  type    = string
  default = "sre-showcase"
}

variable "ce_project_name" {
  type    = string
  default = "proj11-sre-ce"
}

variable "cos_name" {
  type    = string
  default = "proj11-cos"
}

variable "cos_bucket" {
  type    = string
  default = "proj11-sre-bucket"
}

variable "tf_state_bucket" {
  type    = string
  default = "proj11-tfstate"
}

variable "logdna_name" {
  type    = string
  default = "proj11-logdna"
}

variable "sysdig_name" {
  type    = string
  default = "proj11-sysdig"
}

variable "secretsmgr_name" {
  type    = string
  default = "proj11-secrets"
}
