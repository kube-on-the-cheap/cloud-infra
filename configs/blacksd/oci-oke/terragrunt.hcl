terraform {
  source = "../../..//modules/oci-oke"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

inputs = {
  oke_k8s_cluster_version = "1.34.1"
  oke_k8s_workers_version = "1.34.1"
}
