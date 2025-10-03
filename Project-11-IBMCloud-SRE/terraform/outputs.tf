output "icr_namespace" { value = ibm_cr_namespace.ns.name }
output "cos_bucket" { value = ibm_cos_bucket.app_bucket.bucket_name }
output "tfstate_bucket" { value = ibm_cos_bucket.tfstate_bucket.bucket_name }
output "secrets_manager" { value = ibm_resource_instance.secrets.crn }
output "sysdig_crn" { value = ibm_resource_instance.sysdig.crn }
output "ce_project_id" { value = ibm_code_engine_project.ce.project_id }
