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

inputs = merge(
  yamldecode(sops_decrypt_file("tailscale_oauth.sops.yaml")),
  {
    # Vault coordinates to store the Tailscale secrets
    oke_compartment_id       = dependency.oci-oke.outputs.oke_compartment_ocid
    externalsecrets_key_id   = dependency.oci-oke.outputs.oke_external_secrets_key_ocid
    externalsecrets_vault_id = dependency.oci-oke.outputs.oke_vault_ocid
  }
)
