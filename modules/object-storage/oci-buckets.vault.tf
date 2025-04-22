variable "oke_compartment_id" {
  description = "The OCID of the compartment to create the OKE resources in"
  type        = string
}

variable "externalsecrets_key_id" {
  description = "The OCID of the OKE ExternalSecrets encryption key"
  type        = string
}

variable "externalsecrets_vault_id" {
  description = "The OCID of the vault containing the OKE ExternalSecrets encryption key"
  type        = string
}

resource "oci_vault_secret" "s3_buckets_credentials" {
  for_each = { for bucket_name, bucket_params in var.oci_buckets : bucket_name => bucket_params if bucket_params.create_s3_access_key && bucket_params.store_s3_credentials_in_vault }

  compartment_id = var.oke_compartment_id
  key_id         = var.externalsecrets_key_id
  vault_id       = var.externalsecrets_vault_id

  secret_name = format("S3Credentials%s", title(each.key))
  description = "The S3 Credentials (Access Key and Secret Key) for bucket '${each.key}'."

  # freeform_tags = {"Department"= "Finance"}
  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode({
      AccessKey = {
        UserName        = each.key
        Status          = title(lower(oci_identity_customer_secret_key.bucket_secret_key[each.key].state))
        CreateDate      = oci_identity_customer_secret_key.bucket_secret_key[each.key].time_created
        AccessKeyId     = oci_identity_customer_secret_key.bucket_secret_key[each.key].id
        SecretAccessKey = oci_identity_customer_secret_key.bucket_secret_key[each.key].key
      }
    }))
    name  = "s3_credentials"
    stage = "CURRENT" # INFO: can be CURRENT or PENDING
  }
}

output "s3_buckets_credentials_secret_names" {
  description = "The OCI Vault secret name and keys for all S3-compatible credentials"

  value = { for bucket_name, bucket_params in var.oci_buckets :
    bucket_name => {
      secret_name = oci_vault_secret.s3_buckets_credentials[bucket_name].secret_name
      secret_key  = one(oci_vault_secret.s3_buckets_credentials[bucket_name].secret_content.*.name)
    } if bucket_params.create_s3_access_key && bucket_params.store_s3_credentials_in_vault
  }
}
