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

variable "oauth_client_name" {
  description = "Description for the Tailscale OAuth client"
  type        = string
}

locals {
  oauth_client_scopes = ["devices:core", "auth_keys", "services"]
}

variable "oauth_client_tags" {
  description = "Tags that the OAuth client can assign to devices"
  type        = list(string)
}

resource "tailscale_oauth_client" "this" {
  description = "OAuth client for ${var.oauth_client_name}"
  scopes      = local.oauth_client_scopes
  tags        = var.oauth_client_tags

  depends_on = [tailscale_acl.this]
}

# INFO: !! UGLY WORKAROUND !! OCI doesn't allow specifying 'name' when updating existing secrets
data "oci_vault_secrets" "existing" {
  compartment_id = var.oke_compartment_id
  vault_id       = var.externalsecrets_vault_id
  name           = "TailscaleOAuth"
}

locals {
  secret_exists = length(data.oci_vault_secrets.existing.secrets) > 0
}

resource "oci_vault_secret" "tailscale_oauth" {
  compartment_id = var.oke_compartment_id
  key_id         = var.externalsecrets_key_id
  vault_id       = var.externalsecrets_vault_id

  secret_name = "TailscaleOAuth"
  description = "The Tailscale OAuth id and secret"

  freeform_tags = {
    "blacksd_tech/repo" = "github.com/onprem-infra"
  }

  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode({
      clientId     = tailscale_oauth_client.this.id
      clientSecret = tailscale_oauth_client.this.key
    }))
    # INFO: !! UGLY WORKAROUND !! OCI doesn't allow specifying 'name' when updating existing secrets
    name  = local.secret_exists ? null : "tailscale_oauth"
    stage = "CURRENT" # INFO: can be CURRENT or PENDING
  }

  # NOTE: max expiry time is 1y in Oracle Vault
  #
  # secret_rules {
  #   rule_type                                     = "SECRET_EXPIRY_RULE"
  #   is_secret_content_retrieval_blocked_on_expiry = true
  #   time_of_absolute_expiry                       = time_rotating.two_years.rotation_rfc3339
  # }
}

output "tailscale_oauth" {
  value = {
    secret_name = oci_vault_secret.tailscale_oauth.secret_name
    secret_key  = one(oci_vault_secret.tailscale_oauth.secret_content.*.name)
  }
}
