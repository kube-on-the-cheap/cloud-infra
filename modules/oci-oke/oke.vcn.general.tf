data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All \\w+ Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_vcn" "oke" {
  compartment_id = oci_identity_compartment.oke.id

  display_name = "OKE Node and Pod Networks"
  dns_label    = "oke"
  cidr_blocks = [
    "172.16.0.0/16"
  ]
}

resource "oci_core_internet_gateway" "oke" {
  compartment_id = oci_identity_compartment.oke.id
  vcn_id         = oci_core_vcn.oke.id

  display_name = "OKE Internet Gateway"
  enabled      = true
}

resource "oci_core_default_route_table" "this" {
  compartment_id             = oci_identity_compartment.oke.id
  manage_default_resource_id = oci_core_vcn.oke.default_route_table_id

  display_name = "OKE Default Route Table"

  route_rules {
    network_entity_id = oci_core_nat_gateway.this.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_service_gateway.private_oci_access.id
    destination       = one(data.oci_core_services.all_services.services).cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "oke_public_lb_route_table" {
  compartment_id = oci_identity_compartment.oke.id
  vcn_id         = oci_core_vcn.oke.id

  display_name = "OKE LB Public Route Table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.oke.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}


resource "oci_core_nat_gateway" "this" {
  compartment_id = oci_identity_compartment.oke.id
  vcn_id         = oci_core_vcn.oke.id

  display_name  = "OKE Default NAT Gateway"
  block_traffic = false
}

# https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm
resource "oci_core_service_gateway" "private_oci_access" {
  compartment_id = oci_identity_compartment.oke.id
  vcn_id         = oci_core_vcn.oke.id

  display_name = "Private Access to Oracle Cloud services"
  services {
    service_id = one(data.oci_core_services.all_services.services).id
  }
}
