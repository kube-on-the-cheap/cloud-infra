<!-- BEGIN_TF_DOCS -->
# Tailscale

This module adds a couple resources used in conjunction with the Tailscale K8s operator.

Unfortunately the Tailscale provider is pretty slim in functionalities offered, so a bunch of manual activities are still required. You'll find a more in-depth explanation [in the docs](https://tailscale.com/kb/1236/kubernetes-operator) but in a nutshell you need to log in to the web console to:

- choose a fancy name for the tailnet
- enable HTTPS
- create an OAuth client with the `Devices Core` and `Auth Keys` write scopes; be careful that the client needs to be scoped to the correct `k8s-operator` tag, which is maintained as part of the ACL for the tailnet.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~>7.27 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | ~>0.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 7.27.0 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.24.0 |

## Resources

| Name | Type |
|------|------|
| [oci_vault_secret.tailscale_oauth](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vault_secret) | resource |
| [tailscale_acl.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/acl) | resource |
| [tailscale_dns_preferences.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/dns_preferences) | resource |
| [tailscale_oauth_client.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/oauth_client) | resource |
| [oci_vault_secrets.existing](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/vault_secrets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oauth_clients"></a> [oauth\_clients](#input\_oauth\_clients) | Map of OAuth clients to create | <pre>map(object({<br/>    tags              = list(string)<br/>    store_in_vault    = optional(bool, false)<br/>    vault_secret_name = optional(string) # defaults to "TailscaleOAuth-{key}" if not set<br/>  }))</pre> | `{}` | no |
| <a name="input_oci_vault_config"></a> [oci\_vault\_config](#input\_oci\_vault\_config) | OCI Vault configuration for storing OAuth secrets | <pre>object({<br/>    compartment_id = string<br/>    vault_id       = string<br/>    key_id         = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_oauth_clients"></a> [oauth\_clients](#output\_oauth\_clients) | OAuth client credentials (for clients not stored in vault) | `"null"` | no |
| <a name="output_vault_secrets"></a> [vault\_secrets](#output\_vault\_secrets) | OCI Vault secrets for OAuth clients | `"null"` | no |
<!-- END_TF_DOCS -->
