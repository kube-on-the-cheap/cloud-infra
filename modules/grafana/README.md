# grafana

<!-- BEGIN_TF_DOCS -->
# Grafana Cloud

Create an Access Policy with the following scopes:

* for the stack creation operation
  * `stacks:read`
  * `stacks:write`
  * `stacks:delete`
* for the access policy scopes:
  * `accesspolicies:read`
  * `accesspolicies:write`
  * `accesspolicies:delete`

You can choose to limit the execution to a subset of IP address.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_dns"></a> [dns](#requirement\_dns) | 3.4.2 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~>3.22 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~>6.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_dns"></a> [dns](#provider\_dns) | 3.4.2 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 3.22.2 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.32.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.0 |

## Resources

| Name | Type |
|------|------|
| [grafana_cloud_access_policy.alloy](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_access_policy) | resource |
| [grafana_cloud_access_policy.otel_home_collector](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_access_policy) | resource |
| [grafana_cloud_access_policy.vantage](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_access_policy) | resource |
| [grafana_cloud_access_policy_token.alloy](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_access_policy_token) | resource |
| [grafana_cloud_access_policy_token.otel_home_collector](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_access_policy_token) | resource |
| [grafana_cloud_access_policy_token.vantage](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_access_policy_token) | resource |
| [grafana_cloud_stack.this](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/cloud_stack) | resource |
| [oci_vault_secret.alloy_token](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vault_secret) | resource |
| [time_rotating.otel_home_collector_three_years](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [time_rotating.three_years](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [dns_cname_record_set.cloud_domain_cname](https://registry.terraform.io/providers/hashicorp/dns/3.4.2/docs/data-sources/cname_record_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_externalsecrets_key_id"></a> [externalsecrets\_key\_id](#input\_externalsecrets\_key\_id) | The OCID of the OKE ExternalSecrets encryption key | `string` | n/a | yes |
| <a name="input_externalsecrets_vault_id"></a> [externalsecrets\_vault\_id](#input\_externalsecrets\_vault\_id) | The OCID of the vault containing the OKE ExternalSecrets encryption key | `string` | n/a | yes |
| <a name="input_oke_compartment_id"></a> [oke\_compartment\_id](#input\_oke\_compartment\_id) | The OCID of the compartment to create the OKE resources in | `string` | n/a | yes |
| <a name="input_cloud_domain_host_grafana"></a> [cloud\_domain\_host\_grafana](#input\_cloud\_domain\_host\_grafana) | The custom URL to set. Must already point to <grafana\_cloud\_slug>.grafana.net. | `string` | `""` | no |
| <a name="input_grafana_cloud_region"></a> [grafana\_cloud\_region](#input\_grafana\_cloud\_region) | The region to run the Grafana Cloud stack in | `string` | `"prod-eu-west-2"` | no |
| <a name="input_grafana_cloud_slug"></a> [grafana\_cloud\_slug](#input\_grafana\_cloud\_slug) | Grafana Cloud slug used to create the corresponding Stack. | `string` | `null` | no |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_alloy_token"></a> [alloy\_token](#output\_alloy\_token) | n/a | `<sensitive>` | yes |
| <a name="output_otel_home_collector_token"></a> [otel\_home\_collector\_token](#output\_otel\_home\_collector\_token) | The otel\_home\_collector API token to push metrics | `"null"` | no |
| <a name="output_vantage-token"></a> [vantage-token](#output\_vantage-token) | The Vantage API token to read metrics | `"null"` | no |
<!-- END_TF_DOCS -->
