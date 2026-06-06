# zitadel

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_zitadel"></a> [zitadel](#requirement\_zitadel) | ~> 1.2 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_zitadel_domain"></a> [zitadel\_domain](#input\_zitadel\_domain) | Hostname of the self-hosted Zitadel instance. | `string` | `"auth.cloud.blacksd.tech"` | no |
| <a name="input_zitadel_jwt_profile_json"></a> [zitadel\_jwt\_profile\_json](#input\_zitadel\_jwt\_profile\_json) | Service-account JSON key (whole document, inline) for the Terraform machine user. Provided by Terragrunt via SOPS decrypt of zitadel-key.sops.json. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
