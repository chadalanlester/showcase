data "oci_containerengine_cluster_option" "options" {
  compartment_id = var.compartment_ocid
}

locals {
  auto_version = length(data.oci_containerengine_cluster_option.options.kubernetes_versions) > 0 ?
    data.oci_containerengine_cluster_option.options.kubernetes_versions[
      length(data.oci_containerengine_cluster_option.options.kubernetes_versions) - 1
    ] : "v1.28.0"
  k8s_version = var.kubernetes_version != "" ? var.kubernetes_version : local.auto_version
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = local.k8s_version
  name               = "${var.project_name}-oke"
  vcn_id             = oci_core_vcn.main.id
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public_subnet.id
  }
  options {
    service_lb_subnet_ids = [oci_core_subnet.public_subnet.id]
    kubernetes_network_config { pods_cidr = "" services_cidr = "" }
    cluster_pod_network_options { cni_type = "OCI_VCN_IP_NATIVE" }
  }
  freeform_tags = var.freeform_tags
}

resource "oci_containerengine_node_pool" "pool" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.oke.id
  kubernetes_version = local.k8s_version
  name               = "${var.project_name}-pool-a1"
  node_shape         = "VM.Standard.A1.Flex"
  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gbs
  }
  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private_subnet.id
    }
    size = var.node_count
    nsg_ids = [oci_core_network_security_group.node_nsg.id]
    is_pv_encryption_in_transit_enabled = true
  }
  initial_node_labels { key = "project", value = var.project_name }
  freeform_tags = var.freeform_tags
}
