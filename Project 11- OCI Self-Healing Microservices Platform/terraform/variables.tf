variable "tenancy_ocid" { type = string }
variable "compartment_ocid" { type = string }
variable "region" { type = string  default = "us-phoenix-1" }

variable "project_name" {
  type    = string
  default = "proj11-self-healing"
}

variable "freeform_tags" {
  type = map(string)
  default = {
    project = "proj11-self-healing"
    owner   = "showcase"
  }
}

variable "kubernetes_version" {
  type    = string
  default = ""
}

variable "node_count"      { type = number default = 2 }
variable "node_ocpus"      { type = number default = 1 }
variable "node_memory_gbs" { type = number default = 6 }

variable "vcn_cidr"            { type = string default = "10.0.0.0/16" }
variable "public_subnet_cidr"  { type = string default = "10.0.10.0/24" }
variable "private_subnet_cidr" { type = string default = "10.0.20.0/24" }

variable "atp_db_name"        { type = string default = "PROJ11DB" }
variable "atp_display_name"   { type = string default = "proj11_atp" }
variable "atp_admin_password" { type = string sensitive = true }

variable "artifact_bucket_name" { type = string default = "proj11-artifacts" }
