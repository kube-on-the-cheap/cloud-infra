terraform {
  source = "../../..//modules/email"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "oci-oke" {
  config_path  = "../oci-oke"
  mock_outputs = jsondecode(file("../oci-oke/output-values.mock.json"))
}

inputs = {
  # Grant access
  oke_iam_dynamic_group_workers_name = dependency.oci-oke.outputs.oke_iam_dynamic_group_workers_name
}
