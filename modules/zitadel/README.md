# zitadel

Terraform module for managing the self-hosted Zitadel instance at
`auth.cloud.blacksd.tech`.

## What this manages

Provider configuration, default-organization discovery, and a placeholder
for future per-client OIDC application resources. No Zitadel resources
are defined in this module today; per-client files (e.g., `grimmory.tf`)
land here in follow-up specs and reference `local.org_id`.

## One-time bootstrap

1. Log into the Zitadel Console at `https://auth.cloud.blacksd.tech`.
2. Create a Service User in the default organization with
   **Access Token Type = JWT**.
3. Grant the Service User `IAM_OWNER` at the org level.
4. Generate a JSON key for the Service User — the Console downloads
   it once.
5. Move the downloaded file to
   `configs/blacksd/zitadel/zitadel-key.sops.json`, then encrypt:
   ```bash
   cd configs/blacksd/zitadel
   sops --encrypt --in-place zitadel-key.sops.json
   ```
6. Verify round-trip:
   ```bash
   sops -d zitadel-key.sops.json | jq -r .type   # → serviceaccount
   ```

The repo-root `.sops.yaml` rule
(`path_regex: \.sops(?:\.(?:yaml|json))?$`) matches the file
automatically.

## Day-to-day workflow

```bash
devbox shell
cd configs/blacksd/zitadel
terragrunt init    # first run only
terragrunt plan
terragrunt apply
```

## Adding a new OIDC client

New per-client resources land as sibling `.tf` files inside
`modules/zitadel/` (e.g., `modules/zitadel/grimmory.tf`) in their own
follow-up specs. Reference `local.org_id` for the org context.

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
| [zitadel_application_oidc.grimmory](https://registry.terraform.io/providers/zitadel/zitadel/latest/docs/resources/application_oidc) | resource |
| [zitadel_project.homelab](https://registry.terraform.io/providers/zitadel/zitadel/latest/docs/resources/project) | resource |
| [zitadel_orgs.default](https://registry.terraform.io/providers/zitadel/zitadel/latest/docs/data-sources/orgs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_zitadel_domain"></a> [zitadel\_domain](#input\_zitadel\_domain) | Hostname of the self-hosted Zitadel instance. | `string` | `"auth.cloud.blacksd.tech"` | no |
| <a name="input_zitadel_jwt_profile_json"></a> [zitadel\_jwt\_profile\_json](#input\_zitadel\_jwt\_profile\_json) | Service-account JSON key (whole document, inline) for the Terraform machine user. Provided by Terragrunt via SOPS decrypt of zitadel-key.sops.json. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grimmory_client_id"></a> [grimmory\_client\_id](#output\_grimmory\_client\_id) | Client ID for the Grimmory OIDC application. Paste into Grimmory Settings → OIDC. Marked sensitive because the Zitadel provider schema flags `client_id` as sensitive; read with `terragrunt output -raw grimmory_client_id`. |
<!-- END_TF_DOCS -->
