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
