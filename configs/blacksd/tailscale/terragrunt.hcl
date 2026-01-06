terraform {
  source = "../../..//modules/tailscale/"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "oci-oke" {
  config_path  = "../oci-oke"
  mock_outputs = jsondecode(file("../oci-oke/output-values.mock.json"))
}

inputs = {
  oauth_clients = {
    freeloader = {
      tags              = ["tag:k8s-operator-freeloader", "tag:k8s-freeloader", "tag:k8s-exit-node-freeloader"]
      store_in_vault    = true
      vault_secret_name = "TailscaleOAuth" # backwards compatible with existing ExternalSecret
    }
    understairs = {
      tags           = ["tag:k8s-operator-understairs", "tag:k8s-understairs", "tag:k8s-exit-node-understairs"]
      store_in_vault = false
    }
  }
  oci_vault_config = {
    compartment_id = dependency.oci-oke.outputs.oke_compartment_ocid
    key_id         = dependency.oci-oke.outputs.oke_external_secrets_key_ocid
    vault_id       = dependency.oci-oke.outputs.oke_vault_ocid
  }
}
