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


# resource "oci_core_network_security_group" "permit_ssh" {
#   compartment_id = oci_identity_compartment.oke.id

#   vcn_id       = oci_core_vcn.oke.id
#   display_name = "Permit SSH"
# }

# resource "oci_core_network_security_group_security_rule" "permit_ssh" {
#   network_security_group_id = oci_core_network_security_group.permit_ssh.id

#   protocol    = "6" // TCP
#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"
#   tcp_options {
#     destination_port_range {
#       max = 22
#       min = 22
#     }
#   }
#   direction = "INGRESS"
# }

# ---

# https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm#securitylistconfig__section_jsz_kqw_r4b

## Kubernetes API Endpoint

resource "oci_core_network_security_group" "k8s_api_endpoint" {
  compartment_id = oci_identity_compartment.oke.id

  vcn_id       = oci_core_vcn.oke.id
  display_name = "Allow OKE control plane acceess"
}

# Ingress

resource "oci_core_network_security_group_security_rule" "in_k8s_api_endpoint_nodes_apiserver" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description = "Allow K8s Nodes's AD network in ${each.key} to contact the API Server on default 6443 port"
  protocol    = "6" // TCP
  source      = oci_core_subnet.ad_nodes[each.key].cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
  direction = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_k8s_api_endpoint_node_proxymux" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description = "Allow K8s Nodes's AD network in ${each.key} to contact the API Server on proxymux 12250 port"
  protocol    = "6" // TCP
  source      = oci_core_subnet.ad_nodes[each.key].cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      max = 12250
      min = 12250
    }
  }
  direction = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_k8s_api_endpoint_node_path_type_3" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description = "Allow K8s Nodes's AD network in ${each.key} to send ICMP type 3 packets for path discovery"
  protocol    = "1" // ICMP
  source      = oci_core_subnet.ad_nodes[each.key].cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  icmp_options {
    type = 3
  }
  direction = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_k8s_api_endpoint_node_path_type_4" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description = "Allow K8s Nodes's AD network in ${each.key} to send ICMP type 4 packets for path discovery"
  protocol    = "1" // ICMP
  source      = oci_core_subnet.ad_nodes[each.key].cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  icmp_options {
    type = 4
  }
  direction = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_k8s_api_endpoint_pods_apiserver" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  description = "Allow K8s Pod's regional network to contact the API Server on default 6443 port"
  protocol    = "6" // TCP
  source      = oci_core_subnet.regional_pods.cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
  direction = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_k8s_api_endpoint_pods_proxymux" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  description = "Allow K8s Pod's regional network to contact the API Server on proxymux 12250 port"
  protocol    = "6" // TCP
  source      = oci_core_subnet.regional_pods.cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      max = 12250
      min = 12250
    }
  }
  direction = "INGRESS"
}

# Egress

# https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm
resource "oci_core_network_security_group_security_rule" "out_k8s_api_endpoint_oci_services" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  description      = "Allow K8s Apiserver to initiate connections to OCI Services"
  protocol         = "6" // TCP
  destination      = one(data.oci_core_services.all_services.services).cidr_block
  destination_type = "SERVICE_CIDR_BLOCK"
  stateless        = false
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
  direction = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_k8s_api_endpoint_workers" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description      = "Allow K8s Apiserver to initiate connections to workers"
  protocol         = "6" // TCP
  destination      = oci_core_subnet.ad_nodes[each.key].cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  direction        = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_k8s_api_endpoint_pods" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  description      = "Allow K8s Apiserver to initiate connections to pods"
  protocol         = "all"
  destination      = oci_core_subnet.regional_pods.cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  direction        = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_k8s_api_endpoint_node_path_type_3" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description      = "Allow K8s Apiserver to connect to nodes in AD network in ${each.key} to send ICMP type 3 packets for path discovery"
  protocol         = "1" // ICMP
  destination      = oci_core_subnet.ad_nodes[each.key].cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  icmp_options {
    type = 3
  }
  direction = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_k8s_api_endpoint_node_path_type_4" {
  network_security_group_id = oci_core_network_security_group.k8s_api_endpoint.id

  for_each = toset(keys(local.availability_domains))

  description      = "Allow K8s Apiserver to connect to nodes in AD network in ${each.key} to send ICMP type 4 packets for path discovery"
  protocol         = "1" // ICMP
  destination      = oci_core_subnet.ad_nodes[each.key].cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  icmp_options {
    type = 4
  }
  direction = "EGRESS"
}

## Worker nodes

resource "oci_core_network_security_group" "oke_workers" {
  compartment_id = oci_identity_compartment.oke.id

  vcn_id       = oci_core_vcn.oke.id
  display_name = "Manage workers access"
}

# Ingress

resource "oci_core_network_security_group_security_rule" "in_oke_workers_nodes" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  for_each = toset(keys(local.availability_domains))

  description = "Allow K8s Nodes to talk to each others"
  protocol    = "all"
  source      = oci_core_subnet.ad_nodes[each.key].cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  direction   = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_oke_workers_pods" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description = "Allow K8s Nodes to talk with Pods"
  protocol    = "all"
  source      = oci_core_subnet.regional_pods.cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  direction   = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_oke_workers_k8s_endpoint" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description = "Allow K8s API endpoint to talk with workers"
  protocol    = "6" // TCP
  source      = oci_core_subnet.regional_control_plane.cidr_block
  source_type = "CIDR_BLOCK"
  stateless   = false
  direction   = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_oke_workers_path_type_3" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description = "Allow K8s Nodes to receive ICMP type 3 packets for path discovery"
  protocol    = "1" // ICMP
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false
  icmp_options {
    type = 3
  }
  direction = "INGRESS"
}

resource "oci_core_network_security_group_security_rule" "in_oke_workers_path_type_4" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description = "Allow K8s Nodes to receive ICMP type 4 packets for path discovery"
  protocol    = "1" // ICMP
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false
  icmp_options {
    type = 4
  }
  direction = "INGRESS"
}

# Egress

# https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm
resource "oci_core_network_security_group_security_rule" "out_oke_workers_oci_services" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description      = "Allow K8s workers to initiate connections to OCI Services"
  protocol         = "6" // TCP
  destination      = one(data.oci_core_services.all_services.services).cidr_block
  destination_type = "SERVICE_CIDR_BLOCK"
  stateless        = false
  direction        = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_oke_workers_k8s_api_endpoint" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description      = "Allow K8s workers to initiate connections to K8s API Server"
  protocol         = "6" // TCP
  destination      = oci_core_subnet.regional_control_plane.cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
  direction = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_oke_workers_k8s_api_proxymux" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description      = "Allow K8s workers to initiate connections to K8s API Server proxymux port"
  protocol         = "6" // TCP
  destination      = oci_core_subnet.regional_control_plane.cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  tcp_options {
    destination_port_range {
      max = 12250
      min = 12250
    }
  }
  direction = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_oke_workers_workers" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  for_each = toset(keys(local.availability_domains))

  description      = "Allow K8s workers to initiate connections to workers"
  protocol         = "6" // TCP
  destination      = oci_core_subnet.ad_nodes[each.key].cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  direction        = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_oke_workers_pods" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description      = "Allow K8s workers to initiate connections to pods"
  protocol         = "all"
  destination      = oci_core_subnet.regional_pods.cidr_block
  destination_type = "CIDR_BLOCK"
  stateless        = false
  direction        = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_oke_workers_node_path_type_3" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description      = "Allow K8s workers to connect to send ICMP type 3 packets for path discovery"
  protocol         = "1" // ICMP
  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless        = false
  icmp_options {
    type = 3
  }
  direction = "EGRESS"
}

resource "oci_core_network_security_group_security_rule" "out_oke_workers_node_path_type_4" {
  network_security_group_id = oci_core_network_security_group.oke_workers.id

  description      = "Allow K8s workers to connect to send ICMP type 4 packets for path discovery"
  protocol         = "1" // ICMP
  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless        = false
  icmp_options {
    type = 4
  }
  direction = "EGRESS"
}


# resource "oci_core_network_security_group" "permit_web" {
#   compartment_id = oci_identity_compartment.oke.id

#   vcn_id       = oci_core_vcn.oke.id
#   display_name = "Allow HTTP/HTTPS traffic"
# }

# resource "oci_core_network_security_group_security_rule" "permit_http" {
#   network_security_group_id = oci_core_network_security_group.permit_web.id

#   protocol    = "6" // TCP
#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"
#   tcp_options {
#     destination_port_range {
#       max = 80
#       min = 80
#     }
#   }
#   direction = "INGRESS"
# }

# resource "oci_core_network_security_group_security_rule" "permit_http_alt" {
#   network_security_group_id = oci_core_network_security_group.permit_web.id

#   protocol    = "6" // TCP
#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"
#   tcp_options {
#     destination_port_range {
#       max = 8080
#       min = 8080
#     }
#   }
#   direction = "INGRESS"
# }

# resource "oci_core_network_security_group_security_rule" "permit_https" {
#   network_security_group_id = oci_core_network_security_group.permit_web.id

#   protocol    = "6" // TCP
#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"
#   tcp_options {
#     destination_port_range {
#       max = 443
#       min = 443
#     }
#   }
#   direction = "INGRESS"
# }

# resource "oci_core_network_security_group_security_rule" "permit_https_alt" {
#   network_security_group_id = oci_core_network_security_group.permit_web.id

#   protocol    = "6" // TCP
#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"
#   tcp_options {
#     destination_port_range {
#       max = 8443
#       min = 8443
#     }
#   }
#   direction = "INGRESS"
# }
