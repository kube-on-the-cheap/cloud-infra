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
  oke_iam_dynamic_group_workers_name = dependency.oci-oke.outputs.oke_iam_dynamic_group_workers_name

  # Vault coordinates to store the Bucket secrets
  oke_compartment_id       = dependency.oci-oke.outputs.oke_compartment_ocid
  externalsecrets_key_id   = dependency.oci-oke.outputs.oke_external_secrets_key_ocid
  externalsecrets_vault_id = dependency.oci-oke.outputs.oke_vault_ocid

  # https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm#objectstorage
  oci_buckets = {
    "velero" = {
      storage_tier         = "Archive"
      versioning           = "Disabled"
      retention            = "90 days"
      create_s3_access_key = true
    }
  }
}
