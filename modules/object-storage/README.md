# object-storage

<!-- BEGIN_TF_DOCS -->
# Object Storage

This module is about creating Object Storage buckets, in Oracle Cloud and (future implementation) Google Cloud

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
| [oci_identity_policy.allow_oke_workers_externalsecrets_vault_object_storage](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_user_bucket_access](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.objecstorage_allow_kms_access](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.objecstorage_allow_lifecycle_rules](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_user.bucket_user](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_user) | resource |
| [oci_kms_key.object_storage_encription_key](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_vault) | resource |
| [oci_objectstorage_bucket.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/objectstorage_bucket) | resource |
| [oci_objectstorage_object_lifecycle_policy.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/objectstorage_object_lifecycle_policy) | resource |
| [oci_vault_secret.s3_buckets_credentials](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/vault_secret) | resource |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email_domain_name"></a> [email\_domain\_name](#input\_email\_domain\_name) | The email domain name. | `string` | n/a | yes |
| <a name="input_oci_buckets"></a> [oci\_buckets](#input\_oci\_buckets) | A map of a buckets to create in Oracle Cloud. Bucket name is the key. | <pre>map(object({<br/>    # Standard, Archive<br/>    storage_tier : string,<br/>    # Disabled, Enabled, Suspended<br/>    versioning : string,<br/>    access_type : optional(string, "NoPublicAccess"),<br/>    auto_tiering : optional(string, "Disabled"),<br/>    object_events_enabled : optional(bool, false),<br/>    retention : optional(string),<br/>    lifecycle : optional(string),<br/>    create_s3_access_key : optional(bool, false),<br/>    store_s3_credentials_in_vault : optional(bool, true),<br/>    grant_oke_workers_access : optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_oke_iam_dynamic_group_workers_name"></a> [oke\_iam\_dynamic\_group\_workers\_name](#input\_oke\_iam\_dynamic\_group\_workers\_name) | The OKE IAM dynamic group name for workers | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region name | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCI Tenancy ID | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_object_storage_compartment_ocid"></a> [object\_storage\_compartment\_ocid](#output\_object\_storage\_compartment\_ocid) | The Object Storage compartmnent's OCID | `"ocid1.compartment.oc1..aaaaaaaafdhn4u7r4g97ffh5gnxxakovn80f350220w7nqdjx9o0fgsb8o1e"` | no |
| <a name="output_s3_buckets_credentials_secret_names"></a> [s3\_buckets\_credentials\_secret\_names](#output\_s3\_buckets\_credentials\_secret\_names) | The OCI Vault secret name and keys for all S3-compatible credentials | <pre>{<br/>  "velero": {<br/>    "secret_key": "s3_credentials",<br/>    "secret_name": "S3CredentialsVelero"<br/>  }<br/>}</pre> | no |
| <a name="output_s3_credentials"></a> [s3\_credentials](#output\_s3\_credentials) | S3 Compatibility Layer credentials | `<sensitive>` | yes |
| <a name="output_s3_vault"></a> [s3\_vault](#output\_s3\_vault) | Parameters to configure a [Cluster]SecretStore | `"null"` | no |
<!-- END_TF_DOCS -->
