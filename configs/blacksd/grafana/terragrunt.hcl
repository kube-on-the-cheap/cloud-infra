terraform {
  source = "../../..//modules/grafana"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "oci-oke" {
  config_path  = "../oci-oke"
  mock_outputs = jsondecode(file("../oci-oke/output-values.mock.json"))
}

dependency "dns" {
  config_path  = "../dns"
  mock_outputs = jsondecode(file("../dns/output-values.mock.json"))
}

inputs = {
  # NOTE: "...eh voleeeevi!" - custom domain is not available in the free plan
  # cloud_domain_host_grafana = dependency.dns.outputs.cloud_domain_host_grafana

  # Vault coordinates to store the Grafana Alloy token
  oke_compartment_id       = dependency.oci-oke.outputs.oke_compartment_ocid
  externalsecrets_key_id   = dependency.oci-oke.outputs.oke_external_secrets_key_ocid
  externalsecrets_vault_id = dependency.oci-oke.outputs.oke_vault_ocid
}
