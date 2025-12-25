# dns

<!-- BEGIN_TF_DOCS -->
# DNS Management

This module takes care of creating a zone in DigitalOcean, provide info on how to implement delegation from its parent, and adds the token to be used with ExternalDNS in an OCI Vault Secret for later use.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~>5 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~>2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.15.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.72.0 |

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.cloud_delegation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [digitalocean_domain.cloud](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/domain) | resource |
| [digitalocean_domain.email](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/domain) | resource |
| [digitalocean_project_resources.kotc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_record.email_delegation](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_record.email_dkim](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_record.email_spf](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [cloudflare_zone.parent_domain](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |
| [digitalocean_project.kotc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/project) | data source |
| [digitalocean_records.cloud_ns](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/records) | data source |
| [digitalocean_records.email_ns](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/records) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_domain_name"></a> [cloud\_domain\_name](#input\_cloud\_domain\_name) | The domain used to host cloud resources | `any` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The parent OCI domain name | `any` | n/a | yes |
| <a name="input_email_dkim_cname"></a> [email\_dkim\_cname](#input\_email\_dkim\_cname) | The CNAME to configure to set up DKIM in the domain. | <pre>object({<br/>    selector = string<br/>    dst      = string<br/>  })</pre> | n/a | yes |
| <a name="input_email_spf_txt"></a> [email\_spf\_txt](#input\_email\_spf\_txt) | The TXT record to configure to set up SPF in the domain. | `any` | n/a | yes |
| <a name="input_email_subdomain_name"></a> [email\_subdomain\_name](#input\_email\_subdomain\_name) | The email domain name. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The DigitalOcean project name to create the domain in | `string` | n/a | yes |
<!-- END_TF_DOCS -->
