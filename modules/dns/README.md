# dns

<!-- BEGIN_TF_DOCS -->
# DNS Management

This module takes care of creating a zone in DigitalOcean, provide info on how to implement delegation from its parent, and adds the token to be used with ExternalDNS in an OCI Vault Secret for later use.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~>5.1 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~>2.49 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~>6.26 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~>0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.1.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.49.1 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.30.0 |

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.cloud_delegation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_zone.parent_domain](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) | resource |
| [digitalocean_domain.cloud](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/domain) | resource |
| [digitalocean_project.kotc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project) | resource |
| [digitalocean_project_resources.kotc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_record.grafana](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [oci_vault_secret.do_zone_mgmt](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vault_secret) | resource |
| [digitalocean_records.cloud_ns](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/records) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_account_id"></a> [cf\_account\_id](#input\_cf\_account\_id) | The Cloudflare Account ID | `string` | n/a | yes |
| <a name="input_do_token_zone_mgmt"></a> [do\_token\_zone\_mgmt](#input\_do\_token\_zone\_mgmt) | The DigitalOcean API token to use for the ExternalDNS provider | `string` | n/a | yes |
| <a name="input_do_token_zone_mgmt_expiry_date"></a> [do\_token\_zone\_mgmt\_expiry\_date](#input\_do\_token\_zone\_mgmt\_expiry\_date) | The date the DigitalOcean API token expires, in RFC 3339 format (2017-11-22T01:00:00Z) | `string` | n/a | yes |
| <a name="input_externalsecrets_key_id"></a> [externalsecrets\_key\_id](#input\_externalsecrets\_key\_id) | The OCID of the OKE ExternalSecrets encryption key | `string` | n/a | yes |
| <a name="input_externalsecrets_vault_id"></a> [externalsecrets\_vault\_id](#input\_externalsecrets\_vault\_id) | The OCID of the vault containing the OKE ExternalSecrets encryption key | `string` | n/a | yes |
| <a name="input_grafana_cloud_slug"></a> [grafana\_cloud\_slug](#input\_grafana\_cloud\_slug) | Grafana Cloud slug used to create the corresponding Stack. | `string` | n/a | yes |
| <a name="input_oke_compartment_id"></a> [oke\_compartment\_id](#input\_oke\_compartment\_id) | The OCID of the compartment to create the OKE resources in | `string` | n/a | yes |
| <a name="input_parent_domain"></a> [parent\_domain](#input\_parent\_domain) | The parent domain to delegate the subdomain to | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The DigitalOcean project name to create the domain in | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_cloud_domain_host_grafana"></a> [cloud\_domain\_host\_grafana](#output\_cloud\_domain\_host\_grafana) | Grafana Cloud custom domain's FQDN. | `"grafana.cloud.domain.com"` | no |
| <a name="output_cloud_domain_ns"></a> [cloud\_domain\_ns](#output\_cloud\_domain\_ns) | Nameservers for the delegated zone. Add these records as NS type records in the parent domain to perform zone delegation. | <pre>[<br/>  "ns1.cloudflare.com",<br/>  "ns2.cloudflare.com",<br/>  "ns3.cloudflare.com"<br/>]</pre> | no |
| <a name="output_do_token"></a> [do\_token](#output\_do\_token) | n/a | <pre>{<br/>  "secret_key": "equinix-token",<br/>  "secret_name": "EquinixCloudZoneManagement"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
