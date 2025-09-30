resource "oci_identity_dynamic_group" "funcs" {
  compartment_id = var.tenancy_ocid
  description    = "Proj11 Functions dynamic group"
  name           = "${var.project_name}-dg-funcs"
  matching_rule  = "ALL { resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}' }"
}

resource "oci_identity_policy" "proj_policy" {
  compartment_id = var.compartment_ocid
  name           = "${var.project_name}-policy"
  description    = "Policies for Functions to access OS and ADB"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.funcs.name} to manage objects in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.funcs.name} to read autonomous-database-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.funcs.name} to inspect compartments in tenancy"
  ]
  freeform_tags = var.freeform_tags
}
