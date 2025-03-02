terraform {
  source = "../../..//modules/oci-oke"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}
