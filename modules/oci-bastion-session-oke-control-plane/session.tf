locals {
  session_ttl_in_seconds = 7200 # 2h
}

variable "bastion_ocid" {
  description = "The Bastion OCID"
  type        = string
}

resource "oci_bastion_session" "oke_control_plane_access" {
  bastion_id = var.bastion_ocid

  display_name = "oke-k8s-access"

  key_details {
    public_key_content = coalesce(
      var.ssh_public_key,
      one(tls_private_key.session_key.*.public_key_openssh)
    )
  }
  target_resource_details {
    # a PORT_FORWARDING type with the private control plane address and port also works, but you need to change the kubeconfig host to point to 127.0.0.1 and the forwarded port
    session_type = "DYNAMIC_PORT_FORWARDING"
  }

  key_type               = "PUB"
  session_ttl_in_seconds = local.session_ttl_in_seconds
}
