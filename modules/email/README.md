# email

<!-- BEGIN_TF_DOCS -->
# Email

This module configures email delivery for Oracle Cloud Infrastructure.

It builds a domain for delivery, creates the necessary user and permissions to enable email submission using APIs and SMTP and stores credentials in Oracle Vault.

## SMTP test

```bash
SMTP_SERVER=$(terragrunt output -json | jq -r '.email_submission_endpoints.value.smtp.endpoint')
SMTP_USERNAME=$(terragrunt output -json | jq -r '.email_submission_credentials_user_sender.value.username')
SMTP_PASSWORD=$(terragrunt output -json | jq -r '.email_submission_credentials_user_sender.value.password')

AUTHORIZED_SENDER="<authorized_sender>@mail.cloud.blacksd.tech"

nix run nixpkgs#swaks -- --pipeline -tls --to '<valid_recipient>@gmail.com' \
--server ${SMTP_SERVER} --port 587 \
--from ${AUTHORIZED_SENDER} \
--auth-user ${SMTP_USERNAME} \
--auth-password ${SMTP_PASSWORD} \
--header 'Subject: Test Email from Oracle Cloud' \
--body 'This is a test mail from Oracle Cloud.'
```

## API test

TODO: but will probably use [this API call](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/api/#/en/emaildeliverysubmission/20220926/EmailSubmittedResponse/SubmitEmail)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.35.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.35.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
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
| [oci_identity_user.sender](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_user) | resource |
| [oci_identity_user_group_membership.sender_group_membership](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/identity_user_group_membership) | resource |
| [oci_kms_key.email_encription_key](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/kms_vault) | resource |
| [oci_vault_secret.sender_credentials](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/resources/vault_secret) | resource |
| [random_string.selector](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.dkim_key](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |
| [oci_email_configuration.this](https://registry.terraform.io/providers/oracle/oci/6.35.0/docs/data-sources/email_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email_subdomain_name"></a> [email\_subdomain\_name](#input\_email\_subdomain\_name) | The email domain name. | `string` | n/a | yes |
| <a name="input_oke_iam_dynamic_group_workers_name"></a> [oke\_iam\_dynamic\_group\_workers\_name](#input\_oke\_iam\_dynamic\_group\_workers\_name) | The OKE IAM dynamic group name for workers | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region name | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCI Tenancy ID | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_dkim_cname"></a> [dkim\_cname](#output\_dkim\_cname) | The CNAME to configure to set up DKIM in the domain. | <pre>{<br/>  "dst": "selector-r4nd0m.mail.my.domain.dkim.fra1.oracleemaildelivery.com.",<br/>  "selector": "selector-r4nd0m"<br/>}</pre> | no |
| <a name="output_email_submission_credentials_user_sender"></a> [email\_submission\_credentials\_user\_sender](#output\_email\_submission\_credentials\_user\_sender) | Credentials to use for submitting emails with user 'sender'. | `<sensitive>` | yes |
| <a name="output_email_submission_endpoints"></a> [email\_submission\_endpoints](#output\_email\_submission\_endpoints) | The addresses where to send emails. | <pre>{<br/>  "http": {<br/>    "endpoint": "cell9.submit.email.eu-frankfurt-1.oci.oraclecloud.com"<br/>  },<br/>  "smtp": {<br/>    "endpoint": "smtp.email.eu-frankfurt-1.oci.oraclecloud.com"<br/>  }<br/>}</pre> | no |
| <a name="output_email_vault"></a> [email\_vault](#output\_email\_vault) | Parameters to configure a [Cluster]SecretStore | <pre>{<br/>  "spec": {<br/>    "provider": {<br/>      "oracle": {<br/>        "compartment": "ocid1.compartment.oc1..aaaaaaaanp72xpoq7fcpw8krcr4i2d2se5jspzgj2izvnfyvsdq43qmqfpy5",<br/>        "encryptionKey": "ocid1.key.oc1.eu-frankfurt-1.uqd6ladtctfiv.kgyzcv0nmueyl1lls31mwbuctvb2chreos5yaql9av7no1b1sscfcz1d7506",<br/>        "principalType": "InstancePrincipal",<br/>        "region": "eu-frankfurt-1",<br/>        "vault": "ocid1.vault.oc1.eu-frankfurt-1.czrs4579k16lh.f1344zj67j739cwo5ka4d3qibagj099s2fckletlhlct2en1leerfqxr1s8k"<br/>      }<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="output_spf_txt"></a> [spf\_txt](#output\_spf\_txt) | The TXT record to configure to set up SPF in the domain. | `"v=spf1 include:eu.rp.oracleemaildelivery.com ~all"` | no |
<!-- END_TF_DOCS -->
