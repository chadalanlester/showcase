resource "oci_database_autonomous_database" "atp" {
  compartment_id            = var.compartment_ocid
  db_name                   = var.atp_db_name
  display_name              = var.atp_display_name
  admin_password            = var.atp_admin_password
  cpu_core_count            = 1
  data_storage_size_in_gbs  = 20
  db_workload               = "OLTP"
  is_auto_scaling_enabled   = false
  is_free_tier              = true
  is_data_guard_enabled     = false
  is_access_control_enabled = false
  license_model             = "LICENSE_INCLUDED"
  freeform_tags             = var.freeform_tags
}
