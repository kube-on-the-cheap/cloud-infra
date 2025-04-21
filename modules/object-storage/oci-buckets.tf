data "oci_objectstorage_namespace" "this" {
  compartment_id = oci_identity_compartment.object_storage.id
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
        time_amount = regex("\\d+", retention_rules.value)
        time_unit   = regex("\\D+", retention_rules.value)
      }
    }
  }

  versioning = each.value.object_events_enabled

  depends_on = [
    oci_identity_policy.objecstorage_allow_kms_access
  ]
}
