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

resource "oci_vault_secret" "alloy_cloud_token" {
  compartment_id = var.oke_compartment_id
  key_id         = var.externalsecrets_key_id
  vault_id       = var.externalsecrets_vault_id

  secret_name = "GrafanaCloudAccessPolicyToken"
  description = "The Access Policy Token used for Grafana Alloy deployment"

  secret_content {
    content_type = "BASE64"
    content      = base64encode(grafana_cloud_access_policy_token.alloy_cloud.token)
    stage        = "CURRENT"
  }

  # NOTE: max expiry time is 1y in Oracle Vault
  #
  # secret_rules {
  #   rule_type                                     = "SECRET_EXPIRY_RULE"
  #   is_secret_content_retrieval_blocked_on_expiry = true
  #   time_of_absolute_expiry                       = time_rotating.two_years.rotation_rfc3339
  # }
}

output "alloy_cloud_token" {
  # secret_key removed: the OCI secret content version name is not consumed downstream
  value = {
    secret_name = oci_vault_secret.alloy_cloud_token.secret_name
  }
}
