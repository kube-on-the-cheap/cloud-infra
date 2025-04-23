terraform {
  source = "../../..//modules/object-storage"
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
  oke_compartment_id                 = dependency.oci-oke.outputs.oke_compartment_ocid
  oke_iam_dynamic_group_workers_name = dependency.oci-oke.outputs.oke_iam_dynamic_group_workers_name

  # https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm#objectstorage
  oci_buckets = {
    "velero" = {
      storage_tier         = "Standard"
      versioning           = "Disabled"
      lifecycle            = "90 days, delete"
      create_s3_access_key = true
    }
  }
}
