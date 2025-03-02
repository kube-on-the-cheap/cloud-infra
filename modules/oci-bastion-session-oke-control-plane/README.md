# oci-oke-bastion-session-control-plane

<!-- BEGIN_TF_DOCS -->
# Control Plane bastion session

This module creates a temporary session to the OKE Control Plane's private endpoint through the dedicated Bastion.

TODO: detail the SOCKS method

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.23.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Resources

| Name | Type |
|------|------|
| [local_file.pub_session_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.session_access_info](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.session_env_vars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.session_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.pvt_session_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [oci_bastion_session.oke_control_plane_access](https://registry.terraform.io/providers/oracle/oci/6.23.0/docs/resources/bastion_session) | resource |
| [time_rotating.session_expire](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [tls_private_key.session_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ocid"></a> [bastion\_ocid](#input\_bastion\_ocid) | The Bastion OCID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region name | `string` | n/a | yes |
| <a name="input_session_data_dir"></a> [session\_data\_dir](#input\_session\_data\_dir) | The path where to store files with the session data | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The SSH public key, in OpenSSH format. If not provided, an ephemeral key will be generated for this session. | `string` | `""` | no |
<!-- END_TF_DOCS -->
