data "ibm_resource_group" "rg" { name = var.resource_group }

resource "ibm_cr_namespace" "ns" {
  name = var.icr_namespace
}

resource "ibm_resource_instance" "cos" {
  name              = var.cos_name
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.rg.id
}

resource "ibm_resource_key" "cos_hmac" {
  name                 = "${var.cos_name}-hmac"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos.id
  parameters = { HMAC = true }
}

resource "ibm_cos_bucket" "app_bucket" {
  bucket_name          = var.cos_bucket
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "smart"
}

resource "ibm_cos_bucket" "tfstate_bucket" {
  bucket_name          = var.tf_state_bucket
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "smart"
}

resource "ibm_resource_instance" "secrets" {
  name              = var.secretsmgr_name
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = data.ibm_resource_group.rg.id
}

resource "ibm_resource_instance" "sysdig" {
  name              = var.sysdig_name
  service           = "sysdig-monitor"
  plan              = "lite"
  location          = var.region
  resource_group_id = data.ibm_resource_group.rg.id
}

resource "ibm_code_engine_project" "ce" {
  name              = var.ce_project_name
  resource_group_id = data.ibm_resource_group.rg.id
}
