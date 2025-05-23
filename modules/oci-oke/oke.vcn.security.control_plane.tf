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
