variable "oauth_clients" {
  description = "Map of OAuth clients to create"
  type = map(object({
    tags              = list(string)
    store_in_vault    = optional(bool, false)
    vault_secret_name = optional(string) # defaults to "TailscaleOAuth-{key}" if not set
  }))
  default = {}
}

# OCI Vault configuration (only required if any client needs vault storage)
variable "oci_vault_config" {
  description = "OCI Vault configuration for storing OAuth secrets"
  type = object({
    compartment_id = string
    vault_id       = string
    key_id         = string
  })
  default = null
}

locals {
  oauth_client_scopes   = ["devices:core", "auth_keys", "services"]
  clients_needing_vault = { for k, v in var.oauth_clients : k => v if v.store_in_vault }
  vault_secret_names = {
    for k, v in local.clients_needing_vault :
    k => coalesce(v.vault_secret_name, "TailscaleOAuth-${k}")
  }
}

resource "tailscale_oauth_client" "this" {
  for_each = var.oauth_clients

  description = "OAuth client for ${each.key}"
  scopes      = local.oauth_client_scopes
  tags        = each.value.tags

  depends_on = [tailscale_acl.this]
}

# OCI Vault secrets (only for clients that need it)
# INFO: !! UGLY WORKAROUND !! OCI doesn't allow specifying 'name' when updating existing secrets
data "oci_vault_secrets" "existing" {
  for_each = local.clients_needing_vault

  compartment_id = var.oci_vault_config.compartment_id
  vault_id       = var.oci_vault_config.vault_id
  name           = local.vault_secret_names[each.key]
}

locals {
  secret_exists = {
    for k, v in local.clients_needing_vault :
    k => length(data.oci_vault_secrets.existing[k].secrets) > 0
  }
}

resource "oci_vault_secret" "tailscale_oauth" {
  for_each = local.clients_needing_vault

  compartment_id = var.oci_vault_config.compartment_id
  key_id         = var.oci_vault_config.key_id
  vault_id       = var.oci_vault_config.vault_id

  secret_name = local.vault_secret_names[each.key]
  description = "Tailscale OAuth credentials for ${each.key}"

  freeform_tags = {
    "blacksd_tech/repo" = "github.com/cloud-infra"
  }

  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode({
      client_id     = tailscale_oauth_client.this[each.key].id
      client_secret = tailscale_oauth_client.this[each.key].key
    }))
    # INFO: !! UGLY WORKAROUND !! OCI doesn't allow specifying 'name' when updating existing secrets
    name  = local.secret_exists[each.key] ? null : "tailscale_oauth_${each.key}"
    stage = "CURRENT"
  }
}

output "oauth_clients" {
  description = "OAuth client credentials (for clients not stored in vault)"
  value = {
    for k, v in tailscale_oauth_client.this : k => {
      client_id     = v.id
      client_secret = v.key
    } if !var.oauth_clients[k].store_in_vault
  }
  sensitive = true
}

output "vault_secrets" {
  description = "OCI Vault secrets for OAuth clients"
  value = {
    for k, v in oci_vault_secret.tailscale_oauth : k => {
      secret_name = v.secret_name
    }
  }
}
