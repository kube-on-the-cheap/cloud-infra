locals {
  key_types = {
    # AES: 16, 24, or 32
    "aes" = {
      algorithm = "AES"
      length    = 32
    }
    # RSA: 256, 384, or 512
    "rsa" = {
      algorithm = "RSA"
      length    = 512
    }
    # ECDSA: NIST_P256, NIST_P384 or NIST_P521
    "ecdsa" = {
      algorithm = "ECDSA"
      curve_id  = "NIST_P384"
      length    = 48
    }
  }
}

resource "oci_kms_vault" "this" {
  compartment_id = oci_identity_compartment.object_storage.id

  # NOTE: VIRTUAL_PRIVATE are a paid type
  vault_type   = "DEFAULT"
  display_name = "Object Storage Vault"
  # freeform_tags = {merge(var.shared_freeform_tags, local.kms_freeform_tags)}
}

resource "oci_kms_key" "object_storage_encription_key" {
  compartment_id = oci_identity_compartment.object_storage.id

  display_name = "Object storage AES Master Encryption Key"
  key_shape {
    algorithm = local.key_types.aes.algorithm
    length    = local.key_types.aes.length
  }
  management_endpoint = oci_kms_vault.this.management_endpoint
  # freeform_tags = merge(var.shared_freeform_tags, local.kms_freeform_tags)

  # NOTE: SOFTWARE is free, HSM requires a monthly premium
  protection_mode = "SOFTWARE"

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_identity_policy" "objecstorage_allow_kms_access" {
  compartment_id = var.tenancy_ocid

  name        = "allow_object_storage_key_access"
  description = "Policy to allow bucket Object Storage service to access KMS key ID used for bucket encryption"
  statements = [
    "allow service objectstorage-${var.region} to use keys in compartment id ${oci_identity_compartment.object_storage.id} where target.key.id = '${oci_kms_key.object_storage_encription_key.id}'"
  ]
}
