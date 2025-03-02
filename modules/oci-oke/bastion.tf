locals {
  bastion_allow_list = ["77.32.112.148/32"]
}

variable "session_data_dir" {
  description = "The path where to store files with the session data"
  type        = string
}

resource "oci_bastion_bastion" "control_plane" {
  compartment_id = oci_identity_compartment.oke.id

  name             = "controlplane"
  bastion_type     = "STANDARD"
  target_subnet_id = oci_core_subnet.regional_control_plane.id

  client_cidr_block_allow_list = local.bastion_allow_list
  dns_proxy_status             = "ENABLED"
  max_session_ttl_in_seconds   = "10800" # 3h, maximum allowed
}

resource "oci_bastion_bastion" "nodes" {
  compartment_id = oci_identity_compartment.oke.id

  for_each = toset(keys(local.availability_domains))

  name             = "nodes_${lower(split(":", each.key)[1])}"
  bastion_type     = "STANDARD"
  target_subnet_id = oci_core_subnet.ad_nodes[each.key].id

  client_cidr_block_allow_list = local.bastion_allow_list
  dns_proxy_status             = "ENABLED"
  max_session_ttl_in_seconds   = "10800" # 3h, maximum allowed
}

output "bastion_ocids" {
  description = "The Bastion OCIDs"
  value = {
    control_plane = oci_bastion_bastion.control_plane.id
    workers = { for ad in keys(local.availability_domains) :
      # "eu-frankfurt-1-ad-1" = "ocid1.bastion.oc1.eu-frankfurt-1..."
      lower(split(":", ad)[1]) => oci_bastion_bastion.nodes[ad].id
    }
  }
}
