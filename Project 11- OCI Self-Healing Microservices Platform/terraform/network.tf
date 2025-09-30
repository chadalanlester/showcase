resource "oci_core_vcn" "main" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-vcn"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-igw"
  freeform_tags  = var.freeform_tags
  enabled        = true
}

resource "oci_core_nat_gateway" "nat" {
  block_traffic  = false
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-nat"
  freeform_tags  = var.freeform_tags
}

data "oci_core_services" "all_oci_services" {
  filter { name = "name" values = ["All .* Services In Oracle Services Network"] regex = true }
}

resource "oci_core_service_gateway" "sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-sgw"
  services { service_id = data.oci_core_services.all_oci_services.services[0].id }
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-public-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-private-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }
  route_rules {
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
  freeform_tags = var.freeform_tags
}

resource "oci_core_network_security_group" "lb_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-lb-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "lb_https_ingress" {
  network_security_group_id = oci_core_network_security_group.lb_nsg.id
  direction = "INGRESS"
  protocol  = "6"
  source    = "0.0.0.0/0"
  tcp_options { destination_port_range { min = 443, max = 443 } }
  description = "Allow HTTPS to LoadBalancer"
}

resource "oci_core_network_security_group_security_rule" "lb_http_ingress" {
  network_security_group_id = oci_core_network_security_group.lb_nsg.id
  direction = "INGRESS"
  protocol  = "6"
  source    = "0.0.0.0/0"
  tcp_options { destination_port_range { min = 80, max = 80 } }
  description = "Allow HTTP to LoadBalancer"
}

resource "oci_core_network_security_group" "node_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-node-nsg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "nodeport_ingress_vcn" {
  network_security_group_id = oci_core_network_security_group.node_nsg.id
  direction = "INGRESS"
  protocol  = "6"
  source    = var.vcn_cidr
  tcp_options { destination_port_range { min = 30000, max = 32767 } }
  description = "Allow NodePort range within VCN"
}

resource "oci_core_network_security_group_security_rule" "nodes_egress_all" {
  network_security_group_id = oci_core_network_security_group.node_nsg.id
  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
  description = "Allow egress"
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block        = var.public_subnet_cidr
  display_name      = "${var.project_name}-public-subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main.id
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_vcn.main.default_security_list_id]
  prohibit_public_ip_on_vnic = false
  dns_label         = "pub"
  nsg_ids           = [oci_core_network_security_group.lb_nsg.id]
  freeform_tags     = var.freeform_tags
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet_cidr
  display_name               = "${var.project_name}-private-subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main.id
  route_table_id             = oci_core_route_table.private_rt.id
  security_list_ids          = [oci_core_vcn.main.default_security_list_id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = "pri"
  nsg_ids                    = [oci_core_network_security_group.node_nsg.id]
  freeform_tags              = var.freeform_tags
}
