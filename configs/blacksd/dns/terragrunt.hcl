terraform {
  source = "../../..//modules/dns"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "oci-oke" {
  config_path  = "../oci-oke"
  mock_outputs = jsondecode(file("../oci-oke/output-values.mock.json"))
}

dependency "email" {
  config_path  = "../email"
  mock_outputs = jsondecode(file("../email/output-values.mock.json"))
}

inputs = {
  # Zone details
  parent_domain = "blacksd.tech"

  # Email
  email_dkim_cname = dependency.email.outputs.dkim_cname
  email_spf_txt    = dependency.email.outputs.spf_txt

  # Token used for DNZ zone management
  do_token_zone_mgmt             = lookup(yamldecode(sops_decrypt_file("do_token.sops.yaml")), "do_token")
  do_token_zone_mgmt_expiry_date = "2026-03-01T00:00:00Z"

  # Vault coordinates to store the DO token
  oke_compartment_id       = dependency.oci-oke.outputs.oke_compartment_ocid
  externalsecrets_key_id   = dependency.oci-oke.outputs.oke_external_secrets_key_ocid
  externalsecrets_vault_id = dependency.oci-oke.outputs.oke_vault_ocid
}
