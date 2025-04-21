data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "this" {
  for_each = var.oci_buckets

  compartment_id = oci_identity_compartment.object_storage.id

  name      = each.key
  namespace = data.oci_objectstorage_namespace.this.namespace

  access_type  = each.value.access_type
  auto_tiering = each.value.auto_tiering

  kms_key_id   = oci_kms_key.object_storage_encription_key.id
  storage_tier = each.value.storage_tier

  metadata              = {}
  object_events_enabled = each.value.object_events_enabled

  dynamic "retention_rules" {
    for_each = [each.value.retention]

    content {
      display_name = "Keep objects for ${retention_rules.value}"

      duration {
        #Required
        time_amount = trimspace(regex("\\d+", retention_rules.value))
        time_unit   = upper(trimspace(regex("\\D+", retention_rules.value)))
      }
    }
  }

  versioning = each.value.versioning

  depends_on = [
    oci_identity_policy.objecstorage_allow_kms_access
  ]
}

resource "oci_identity_policy" "allow_oke_workers_buckets" {
  count = anytrue([for _, bucket_params in var.oci_buckets : bucket_params.grant_oke_workers_access]) ? 1 : 0

  compartment_id = oci_identity_compartment.object_storage.id

  name        = "allow_nodes_buckets"
  description = "Policy to allow OKE nodes in group '${var.oke_iam_dynamic_group_workers_name}' to access Buckets"
  statements = [for bucket_name, bucket_params in var.oci_buckets :
    "Allow dynamic-group ${var.oke_iam_dynamic_group_workers_name} to use buckets in compartment id ${oci_identity_compartment.object_storage.id} where all { target.bucket.name='${bucket_name}' }" if bucket_params.grant_oke_workers_access
  ]
}
