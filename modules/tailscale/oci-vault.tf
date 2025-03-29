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

variable "tailscale_oauth_client_id" {
  description = "The Tailscale OAuth Application ID"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.tailscale_oauth_client_id) > 0
    error_message = "The OAuth Application ID needs to be not empty."
  }
}

variable "tailscale_oauth_client_secret" {
  description = "The Tailscale OAuth Application secret"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.tailscale_oauth_client_secret) > 0
    error_message = "The OAuth Application secret needs to be not empty."
  }
}

# TODO: check it's a valid client/secret with
# data "tailscale_users" "all-users" {}

# resource "time_rotating" "two_years" {
#   rotation_years = 2
# }

resource "oci_vault_secret" "tailscale_oauth" {
  compartment_id = var.oke_compartment_id
  key_id         = var.externalsecrets_key_id
  vault_id       = var.externalsecrets_vault_id

  secret_name = "TailscaleOAuth"
  description = "The Tailscale OAuth id and secret"

  # freeform_tags = {"Department"= "Finance"}
  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode({
      clientId     = var.tailscale_oauth_client_id
      clientSecret = var.tailscale_oauth_client_secret
    }))
    name  = "tailscale_oauth"
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
