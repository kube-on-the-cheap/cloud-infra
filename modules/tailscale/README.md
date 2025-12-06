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
| <a name="input_externalsecrets_key_id"></a> [externalsecrets\_key\_id](#input\_externalsecrets\_key\_id) | The OCID of the OKE ExternalSecrets encryption key | `string` | n/a | yes |
| <a name="input_externalsecrets_vault_id"></a> [externalsecrets\_vault\_id](#input\_externalsecrets\_vault\_id) | The OCID of the vault containing the OKE ExternalSecrets encryption key | `string` | n/a | yes |
| <a name="input_oauth_client_name"></a> [oauth\_client\_name](#input\_oauth\_client\_name) | Description for the Tailscale OAuth client | `string` | n/a | yes |
| <a name="input_oauth_client_tags"></a> [oauth\_client\_tags](#input\_oauth\_client\_tags) | Tags that the OAuth client can assign to devices | `list(string)` | n/a | yes |
| <a name="input_oke_compartment_id"></a> [oke\_compartment\_id](#input\_oke\_compartment\_id) | The OCID of the compartment to create the OKE resources in | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_tailscale_oauth"></a> [tailscale\_oauth](#output\_tailscale\_oauth) | n/a | <pre>{<br/>  "secret_key": "tailscale_key",<br/>  "secret_name": "TailscaleSecretName"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
