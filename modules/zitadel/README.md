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
| <a name="input_zitadel_access_token"></a> [zitadel\_access\_token](#input\_zitadel\_access\_token) | Personal access token of the Terraform machine user. Provided by Terragrunt via SOPS decrypt of zitadel-pat.sops.yaml. | `string` | n/a | yes |
| <a name="input_zitadel_domain"></a> [zitadel\_domain](#input\_zitadel\_domain) | Hostname of the self-hosted Zitadel instance. | `string` | `"auth.cloud.blacksd.tech"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
