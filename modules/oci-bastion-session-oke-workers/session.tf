locals {
  session_ttl_in_seconds = 7200 # 2h
}

variable "bastion_ocids" {
  description = "Each subnet node AD's bastion OCID"
  type        = map(string)

  validation {
    condition     = toset(keys(var.bastion_ocids)) == toset(["eu-frankfurt-1-ad-1", "eu-frankfurt-1-ad-2"])
    error_message = "Please add a complete definition for bastions in both eu-frankfurt-1-ad-1 and eu-frankfurt-1-ad-2 zones."
  }
}

resource "oci_bastion_session" "oke_worker_access" {
  for_each = local.node_ocids

  bastion_id   = var.bastion_ocids[each.key]
  display_name = "worker-access-${each.key}"

  key_details {
    public_key_content = coalesce(
      var.ssh_public_key,
      one(tls_private_key.session_key.*.public_key_openssh)
    )
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_operating_system_user_name = "opc"
    target_resource_id                         = each.value
  }

  # TODO: support both types
  # target_resource_details {
  #   target_resource_id = each.value
  #   session_type = "PORT_FORWARDING"
  # }

  key_type               = "PUB"
  session_ttl_in_seconds = local.session_ttl_in_seconds
}
