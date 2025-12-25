<!-- BEGIN_TF_DOCS -->
# Platform bootstrap

This module perform the initial install of the Flux Operator, adds a Flux Instance to start the reconcile sync with an apps config repo.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.flux_instance](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.flux_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.encryption_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_namespace.kube_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_flux_operator_version"></a> [flux\_operator\_version](#input\_flux\_operator\_version) | The Flux Operator version to install | `string` | n/a | yes |
| <a name="input_flux_version"></a> [flux\_version](#input\_flux\_version) | The version of Flux to install | `string` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | The secret decryption key | `string` | n/a | yes |
| <a name="input_session_data_dir"></a> [session\_data\_dir](#input\_session\_data\_dir) | The directory to read session data from | `string` | n/a | yes |
| <a name="input_sync"></a> [sync](#input\_sync) | The info of the Git repository to sync with Flux | <pre>object({<br/>    repo = string<br/>    path = string<br/>    ref  = optional(string, "main")<br/>  })</pre> | n/a | yes |
| <a name="input_components"></a> [components](#input\_components) | The components to install | `list(string)` | <pre>[<br/>  "source-controller",<br/>  "kustomize-controller",<br/>  "helm-controller",<br/>  "notification-controller"<br/>]</pre> | no |
<!-- END_TF_DOCS -->
