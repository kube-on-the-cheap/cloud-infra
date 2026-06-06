# zitadel

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_zitadel"></a> [zitadel](#requirement\_zitadel) | ~> 1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_zitadel"></a> [zitadel](#provider\_zitadel) | 1.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [zitadel_orgs.default](https://registry.terraform.io/providers/zitadel/zitadel/latest/docs/data-sources/orgs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_zitadel_domain"></a> [zitadel\_domain](#input\_zitadel\_domain) | Hostname of the self-hosted Zitadel instance. | `string` | `"auth.cloud.blacksd.tech"` | no |
| <a name="input_zitadel_jwt_profile_json"></a> [zitadel\_jwt\_profile\_json](#input\_zitadel\_jwt\_profile\_json) | Service-account JSON key (whole document, inline) for the Terraform machine user. Provided by Terragrunt via SOPS decrypt of zitadel-key.sops.json. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
