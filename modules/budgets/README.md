<!-- BEGIN_TF_DOCS -->
# Budget Terraform module

This module builds all necessary structures in GCP and OCI to be notified early if there's any spendind associated with the account.

It also maintains users and procedures to integrate [Vantage](https://vantage.sh) in all the Cloud environments to keep accurate track of the spending.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.21.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~>7.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.21.0 |
| <a name="provider_google.billing"></a> [google.billing](#provider\_google.billing) | 6.21.0 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.23.0 |

## Resources

| Name | Type |
|------|------|
| [google_billing_budget.zero_cost](https://registry.terraform.io/providers/hashicorp/google/6.21.0/docs/resources/billing_budget) | resource |
| [google_monitoring_notification_channel.email](https://registry.terraform.io/providers/hashicorp/google/6.21.0/docs/resources/monitoring_notification_channel) | resource |
| [google_project_service.budget_services](https://registry.terraform.io/providers/hashicorp/google/6.21.0/docs/resources/project_service) | resource |
| [oci_budget_alert_rule.scream_bloody_gore](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/budget_alert_rule) | resource |
| [oci_budget_budget.zero_spend](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/budget_budget) | resource |
| [oci_identity_api_key.vantage](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_api_key) | resource |
| [oci_identity_group.vantage](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_group) | resource |
| [oci_identity_policy.vantage](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_user.vantage](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_user) | resource |
| [oci_identity_user_group_membership.vantage](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_user_group_membership) | resource |
| [google_billing_account.this](https://registry.terraform.io/providers/hashicorp/google/6.21.0/docs/data-sources/billing_account) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/6.21.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_billing_account_name"></a> [gcp\_billing\_account\_name](#input\_gcp\_billing\_account\_name) | The billing account name with the payent info | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The GCP project ID to use | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The GCP region the project is located in | `string` | n/a | yes |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | An email to notify about spending thresholds | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCI Tenancy ID | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_oci_vantage_setup_info"></a> [oci\_vantage\_setup\_info](#output\_oci\_vantage\_setup\_info) | Use these informations for vantage.sh setup | `"null"` | no |
<!-- END_TF_DOCS -->
