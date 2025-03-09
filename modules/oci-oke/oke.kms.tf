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
  compartment_id = oci_identity_compartment.oke.id

  # NOTE: VIRTUAL_PRIVATE are a paid type
  vault_type   = "DEFAULT"
  display_name = "OKE Vault"
  # freeform_tags = {merge(var.shared_freeform_tags, local.kms_freeform_tags)}
}

resource "oci_kms_key" "oke_master_encryption_key" {
  compartment_id = oci_identity_compartment.oke.id

  display_name = "OKE AES Master Encryption Key"
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

resource "oci_identity_policy" "allow_oke_mek" {
  compartment_id = oci_identity_compartment.oke.id

  name        = "allow_oke_use_mek"
  description = "Policy to allow the OKE service to use the Master Encryption Key in Compartment '${oci_identity_compartment.oke.name}'"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.all_oke_clusters.name} to use keys in compartment id ${oci_identity_compartment.oke.id} where target.key.id = '${oci_kms_key.oke_master_encryption_key.id}'"
    # "Allow service oke to use keys in compartment id ${oci_identity_compartment.oke.id} where target.key.id = '${oci_kms_key.oke_master_encryption_key.id}'"
  ]
}

resource "oci_kms_key" "oke_node_encryption_key" {
  compartment_id = oci_identity_compartment.oke.id

  display_name = "OKE AES Node Encryption Key"
  key_shape {
    algorithm = local.key_types.aes.algorithm
    length    = local.key_types.aes.length
  }
  management_endpoint = oci_kms_vault.this.management_endpoint

  # freeform_tags = {}

  # NOTE: SOFTWARE is free, HSM requires a monthly premium
  protection_mode = "SOFTWARE"

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_identity_policy" "allow_oke_nek" {
  compartment_id = oci_identity_compartment.oke.id

  name        = "allow_nodes_use_nek"
  description = "Policy to allow nodes and volumes to in Compartment '${oci_identity_compartment.oke.name}' to use the Node Encryption Key"
  statements = [
    "Allow service blockstorage to use keys in compartment id ${oci_identity_compartment.oke.id} where target.key.id = '${oci_kms_key.oke_node_encryption_key.id}'",
    "Allow any-user to use key-delegates in compartment id ${oci_identity_compartment.oke.id} where ALL {request.principal.type='nodepool', target.key.id = '${oci_kms_key.oke_node_encryption_key.id}'}"
    # "Allow dynamic-group id ${oci_identity_dynamic_group.all_oke_clusters.id} to use keys in compartment '${oci_identity_compartment.oke.name}' where target.key.id = '${oci_kms_key.oke_node_encryption_key.id}'"
  ]
}

resource "oci_kms_key" "oke_external_secrets_key" {
  compartment_id = oci_identity_compartment.oke.id

  display_name = "OKE AES ExternalSecrets Encryption Key"
  key_shape {
    algorithm = local.key_types.aes.algorithm
    length    = local.key_types.aes.length
  }
  management_endpoint = oci_kms_vault.this.management_endpoint
  # freeform_tags = {}

  # NOTE: SOFTWARE is free, HSM requires a monthly premium
  protection_mode = "SOFTWARE"

  lifecycle {
    create_before_destroy = true
  }
}

# NOTE: I know, it would be nice to have a per-workload permissions model, but that requires an Enhanced-type OKE cluster, and that's not cheap!
resource "oci_identity_policy" "allow_oke_workers_externalsecrets_key" {
  compartment_id = oci_identity_compartment.oke.id

  name        = "allow_nodes_use_externalsecrets_key"
  description = "Policy to allow nodes  Compartment '${oci_identity_compartment.oke.name}' to use the ExternalSecrets encryption key"
  statements = [
    "Allow any-user to use key-delegates in compartment id ${oci_identity_compartment.oke.id} where ALL {request.principal.type='nodepool', target.key.id = '${oci_kms_key.oke_external_secrets_key.id}'}"
  ]
}

output "oke_vault_ocid" {
  value       = oci_kms_vault.this.id
  description = "The OCID of the OKE Vault"
}

output "oke_external_secrets_key_ocid" {
  description = "The key ID for the OKE ExternalSecrets encryption key"
  value       = oci_kms_key.oke_external_secrets_key.id
}
