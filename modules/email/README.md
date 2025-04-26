# email

<!-- BEGIN_TF_DOCS -->
# Email

This module configures email delivery for Oracle Cloud Infrastructure.

It builds a domain for delivery, creates the necessary user and permissions to enable email submission using APIs and SMTP and stores credentials in Oracle Vault.

```bash
SMTP_SERVER=$(terragrunt output -json | jq -r '.email_submission_endpoints.value.smtp')
SMTP_USERNAME=$(terragrunt output -json | jq -r '.smtp_credentials.value.mailer.username')
SMTP_PASSWORD=$(terragrunt output -json | jq -r '.smtp_credentials.value.mailer.password')

AUTHORIZED_SENDER="do-not-reply@oci.cloud.blacksd.tech"

nix run nixpkgs#swaks -- --pipeline -tls --to 'valid-recipient@gmail.com' \
--server ${SMTP_SERVER} --port 587 \
--from ${AUTHORIZED_SENDER} \
--auth-user ${SMTP_USERNAME} \
--auth-password ${SMTP_PASSWORD} \
--header 'Subject: Test Email from Oracle Cloud' \
--body 'Sample text'
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.35.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.35.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [oci_email_dkim.this](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/email_dkim) | resource |
| [oci_email_email_domain.this](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/email_email_domain) | resource |
| [oci_email_sender.do_not_reply](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/email_sender) | resource |
| [oci_email_sender.notifications](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/email_sender) | resource |
| [oci_identity_compartment.email](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_compartment) | resource |
| [oci_identity_customer_secret_key.sender_secret_key](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_customer_secret_key) | resource |
| [oci_identity_group.sender_group](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_group) | resource |
| [oci_identity_policy.allow_email_tenancy](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_oke_workers_externalsecrets_vault_email](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_sender_smtp](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_policy) | resource |
| [oci_identity_smtp_credential.sender_smtp_credential](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_smtp_credential) | resource |
| [oci_identity_user.mailer](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_user) | resource |
| [oci_identity_user_group_membership.test_user_group_membership](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_user_group_membership) | resource |
| [oci_kms_key.email_encription_key](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/kms_vault) | resource |
| [tls_private_key.dkim_key](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |
| [oci_email_configuration.this](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/data-sources/email_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email_domain_name"></a> [email\_domain\_name](#input\_email\_domain\_name) | The email domain name. | `string` | n/a | yes |
| <a name="input_oke_iam_dynamic_group_workers_name"></a> [oke\_iam\_dynamic\_group\_workers\_name](#input\_oke\_iam\_dynamic\_group\_workers\_name) | The OKE IAM dynamic group name for workers | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region name | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCI Tenancy ID | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_dkim_cname"></a> [dkim\_cname](#output\_dkim\_cname) | The CNAME to configure to set up DKIM in the domain. | `"null"` | no |
| <a name="output_email_submission_endpoints"></a> [email\_submission\_endpoints](#output\_email\_submission\_endpoints) | The addresses where to send emails. | `"null"` | no |
| <a name="output_smtp_credentials"></a> [smtp\_credentials](#output\_smtp\_credentials) | n/a | `"null"` | no |
| <a name="output_spf_txt"></a> [spf\_txt](#output\_spf\_txt) | The TXT record to configure to set up SPF in the domain. | `"null"` | no |
<!-- END_TF_DOCS -->
