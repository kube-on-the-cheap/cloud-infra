# authentik

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_authentik"></a> [authentik](#requirement\_authentik) | ~> 2024.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_authentik"></a> [authentik](#provider\_authentik) | 2024.12.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [authentik_group.admins](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/group) | resource |
| [authentik_group.grownups](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/group) | resource |
| [authentik_group.kids](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/group) | resource |
| [authentik_group.users](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/group) | resource |
| [authentik_user.users](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/user) | resource |
| [random_password.user_initial](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [authentik_flow.authorization](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_flow.invalidation](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_flow.source_authentication](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |
| [authentik_flow.source_enrollment](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/data-sources/flow) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admins"></a> [admins](#input\_admins) | Usernames who get added to the 'admins' Authentik group. Each must be a key in `users`. Provided by Terragrunt via SOPS decrypt of users.sops.yaml (`groups.admins`). | `list(string)` | `[]` | no |
| <a name="input_authentik_token"></a> [authentik\_token](#input\_authentik\_token) | API token for the Terraform-owned admin user. Provided by Terragrunt via SOPS decrypt of authentik-token.sops.yaml. | `string` | n/a | yes |
| <a name="input_authentik_url"></a> [authentik\_url](#input\_authentik\_url) | Base URL of the Authentik instance. | `string` | `"https://login.cloud.blacksd.tech"` | no |
| <a name="input_google_client_id"></a> [google\_client\_id](#input\_google\_client\_id) | Client ID of the Google OAuth client used for the Google source. Provided by Terragrunt via SOPS decrypt of google-oauth.sops.yaml. | `string` | n/a | yes |
| <a name="input_google_client_secret"></a> [google\_client\_secret](#input\_google\_client\_secret) | Client secret of the Google OAuth client used for the Google source. Provided by Terragrunt via SOPS decrypt of google-oauth.sops.yaml. | `string` | n/a | yes |
| <a name="input_grownups"></a> [grownups](#input\_grownups) | Usernames who get added to the 'grownups' Authentik group. Each must be a key in `users`. Provided by Terragrunt via SOPS decrypt of users.sops.yaml (`groups.grownups`). | `list(string)` | `[]` | no |
| <a name="input_kids"></a> [kids](#input\_kids) | Usernames who get added to the 'kids' Authentik group. Each must be a key in `users`. Provided by Terragrunt via SOPS decrypt of users.sops.yaml (`groups.kids`). | `list(string)` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | Map of Authentik human users keyed by username. Provided by Terragrunt via SOPS decrypt of users.sops.yaml. `nick_name` and `preferred_language` are accepted to match the Zitadel module's variable shape (the SOPS file is bit-for-bit reusable) but are silently ignored — Authentik's `authentik_user` resource has no equivalent fields. | <pre>map(object({<br/>    first_name         = string<br/>    last_name          = string<br/>    email              = string<br/>    display_name       = optional(string)<br/>    nick_name          = optional(string)<br/>    preferred_language = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_users_group"></a> [users\_group](#input\_users\_group) | Usernames who get added to the 'users' Authentik group. Each must be a key in `users`. Provided by Terragrunt via SOPS decrypt of users.sops.yaml (`groups.users`). | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
