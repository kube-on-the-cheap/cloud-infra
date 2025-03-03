terraform {
  source = "../../../..//modules/oci-bastion-session-oke-workers"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "oci-oke" {
  config_path  = "../../oci-oke"
  mock_outputs = jsondecode(file("../../oci-oke/output-values.mock.json"))
}

inputs = {
  bastion_ocids      = dependency.oci-oke.outputs.bastion_ocids.workers
  oke_node_pool_ocid = dependency.oci-oke.outputs.oke_node_pool_ocid
  ssh_public_key     = file(format("%s/.ssh/marco_bulgarini.pub", get_env("HOME")))
}
