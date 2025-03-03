terraform {
  source = "../../../..//modules/oci-bastion-session-oke-control-plane"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "oci-oke" {
  config_path  = "../../oci-oke"
  mock_outputs = jsondecode(file("../../oci-oke/output-values.mock.json"))
}

inputs = {
  bastion_ocid = dependency.oci-oke.outputs.bastion_ocids.control_plane
}
