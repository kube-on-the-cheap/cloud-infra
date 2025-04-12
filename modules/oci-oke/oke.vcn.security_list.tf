# https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm#securitylistconfig

# -- Security Lists

resource "oci_core_default_security_list" "vcn_oke" {
  compartment_id             = oci_identity_compartment.oke.id
  manage_default_resource_id = oci_core_vcn.oke.default_security_list_id

  display_name = format("VCN %s Default Security List", oci_core_vcn.oke.display_name)

  egress_security_rules {
    protocol    = "all" // TCP
    description = "Allow outbound"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol    = "all"
    description = "Allow all inter-subnet traffic"
    source      = one(oci_core_vcn.oke.cidr_blocks)
  }
}

resource "oci_core_security_list" "additional_lb" {
  compartment_id = oci_identity_compartment.oke.id

  vcn_id       = oci_core_vcn.oke.id
  display_name = "Load Balancers subnets Additional Security List"

  ingress_security_rules {
    protocol    = "all"
    description = "Allow all Internet traffic"
    source      = "0.0.0.0/0"
  }
}
