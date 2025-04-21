# object-storage

<!-- BEGIN_TF_DOCS -->
# Secrets

This module is about creating a secrets deployment module for resources that

1. Don't have a proper Terraform provider; this would be the preferred way to manage their lifecycle, but if it doesn't exist (and my lab use case isn't big enough to warrant a contribution) it's just best to create the secret manually, encrypt it here and ship it to Vault
2. Don't have any connection to existing other resources from the same scope; it's fine to have a secret shipped to Vault in a module that does other things for the same part of the infra, but if there is no module, it's just best to collect all single-purpose secrets in a single place

See:
* the lack of support for GitHub Apps, [issue ref.](https://github.com/integrations/terraform-provider-github/issues/509)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.26.0 |

## Resources

| Name | Type |
|------|------|
| [oci_identity_compartment.object_storage](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_compartment) | resource |
| [oci_identity_customer_secret_key.bucket_secret_key](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_customer_secret_key) | resource |
| [oci_identity_policy.allow_oke_workers_buckets](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_user_bucket_access](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.objecstorage_allow_kms_access](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_user.bucket_user](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_user) | resource |
| [oci_kms_key.object_storage_encription_key](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_vault) | resource |
| [oci_objectstorage_bucket.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/objectstorage_bucket) | resource |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oci_buckets"></a> [oci\_buckets](#input\_oci\_buckets) | A list of a buckets to create | <pre>map(object({<br/>    # Standard, Archive<br/>    storage_tier : string<br/>    # Disabled, Enabled, Suspended<br/>    versioning : string<br/>    access_type : optional(string, "NoPublicAccess")<br/>    auto_tiering : optional(string, "Disabled"),<br/>    object_events_enabled : optional(bool, false),<br/>    retention : optional(string),<br/>    create_s3_access_key : optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_oke_iam_dynamic_group_workers_name"></a> [oke\_iam\_dynamic\_group\_workers\_name](#input\_oke\_iam\_dynamic\_group\_workers\_name) | The OKE IAM dynamic group name for workers | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region name | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCI Tenancy ID | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_object_storage_compartment_ocid"></a> [object\_storage\_compartment\_ocid](#output\_object\_storage\_compartment\_ocid) | The Object Storage compartmnent's OCID | `"null"` | no |
| <a name="output_s3_credentials"></a> [s3\_credentials](#output\_s3\_credentials) | S3 Compatibility Layer credentials | `"null"` | no |
<!-- END_TF_DOCS -->
