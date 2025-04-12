## Load Balancer security

# INFO: all relevant info available at https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringloadbalancersnetworkloadbalancers-subtopic.htm#contengcreatingloadbalancer_topic-Specifying_Load_Balancer_Security_Rule_Management_Options

resource "oci_core_network_security_group" "lb" {
  compartment_id = oci_identity_compartment.oke.id

  vcn_id       = oci_core_vcn.oke.id
  display_name = "Manage LoadBalancer Access"
}

resource "oci_identity_policy" "allow_lb_manage_nsg" {
  compartment_id = oci_identity_compartment.oke.id

  name        = "allow_lb_manage_nsg"
  description = "Policy to allow the OKE-controller Load Balancers to manage the NSG to control traffic"
  statements = [
    "Allow any-user to manage network-security-groups in compartment id ${oci_identity_compartment.oke.id} where request.principal.type = 'cluster'",
    "Allow any-user to manage vcns in compartment id ${oci_identity_compartment.oke.id} where request.principal.type = 'cluster'",
    "Allow any-user to manage virtual-network-family in compartment id ${oci_identity_compartment.oke.id} where request.principal.type = 'cluster'"
  ]
}

output "oke_nsg_lb_id" {
  value       = oci_core_network_security_group.lb.id
  description = "The ID of the NSG controlled by the Load Balancers"
}
