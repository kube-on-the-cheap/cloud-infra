<!-- BEGIN_TF_DOCS -->
# Oracle Kubernetes

This module builds an OKE Cluster, with a single nodepool spanning two AZs.

It creates a bastion for accessing the control plane, and one bastion for every subnet in every AZ.

TODO: explain the subnetting logic.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.26.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.nodes_pub_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.nodes_pvt_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [oci_bastion_bastion.control_plane](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/bastion_bastion) | resource |
| [oci_bastion_bastion.nodes](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/bastion_bastion) | resource |
| [oci_containerengine_cluster.freeloader](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/containerengine_cluster) | resource |
| [oci_containerengine_node_pool.dishonoredcheques](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/containerengine_node_pool) | resource |
| [oci_core_default_route_table.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_default_route_table) | resource |
| [oci_core_default_security_list.vcn_oke](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_default_security_list) | resource |
| [oci_core_internet_gateway.oke](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_nat_gateway.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_nat_gateway) | resource |
| [oci_core_network_security_group.k8s_api_endpoint](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.oke_workers](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.in_k8s_api_endpoint_node_path_type_3](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_k8s_api_endpoint_node_path_type_4](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_k8s_api_endpoint_node_proxymux](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_k8s_api_endpoint_nodes_apiserver](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_k8s_api_endpoint_pods_apiserver](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_k8s_api_endpoint_pods_proxymux](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_oke_workers_k8s_endpoint](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_oke_workers_nodes](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_oke_workers_path_type_3](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_oke_workers_path_type_4](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.in_oke_workers_pods](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_k8s_api_endpoint_node_path_type_3](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_k8s_api_endpoint_node_path_type_4](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_k8s_api_endpoint_oci_services](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_k8s_api_endpoint_pods](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_k8s_api_endpoint_workers](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_k8s_api_endpoint](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_k8s_api_proxymux](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_node_path_type_3](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_node_path_type_4](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_oci_services](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_pods](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.out_oke_workers_workers](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_route_table.oke_public_lb_route_table](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_route_table) | resource |
| [oci_core_security_list.additional_lb](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_security_list) | resource |
| [oci_core_service_gateway.private_oci_access](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_service_gateway) | resource |
| [oci_core_subnet.ad_lbs](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_subnet) | resource |
| [oci_core_subnet.ad_nodes](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_subnet) | resource |
| [oci_core_subnet.regional_control_plane](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_subnet) | resource |
| [oci_core_subnet.regional_pods](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.oke](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/core_vcn) | resource |
| [oci_identity_compartment.oke](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_compartment) | resource |
| [oci_identity_dynamic_group.all_oke_clusters](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_dynamic_group.all_oke_workers](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_policy.allow_oke_mek](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_oke_nek](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_oke_nodes_update_self](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_identity_policy.allow_oke_workers_externalsecrets](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/identity_policy) | resource |
| [oci_kms_key.oke_external_secrets_key](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_key) | resource |
| [oci_kms_key.oke_master_encryption_key](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_key) | resource |
| [oci_kms_key.oke_node_encryption_key](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/resources/kms_vault) | resource |
| [tls_private_key.node_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [oci_containerengine_cluster_kube_config.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/data-sources/containerengine_cluster_kube_config) | data source |
| [oci_containerengine_node_pool_option.this](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/data-sources/containerengine_node_pool_option) | data source |
| [oci_core_services.all_services](https://registry.terraform.io/providers/oracle/oci/6.26.0/docs/data-sources/core_services) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oke_k8s_cluster_version"></a> [oke\_k8s\_cluster\_version](#input\_oke\_k8s\_cluster\_version) | The Kubernetes version to run in the control plane | `string` | n/a | yes |
| <a name="input_oke_k8s_workers_version"></a> [oke\_k8s\_workers\_version](#input\_oke\_k8s\_workers\_version) | The Kubernetes version to run on the workers | `string` | n/a | yes |
| <a name="input_proxy_port"></a> [proxy\_port](#input\_proxy\_port) | The port the SOCKS5 proxy will listen on | `number` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region name | `string` | n/a | yes |
| <a name="input_session_data_dir"></a> [session\_data\_dir](#input\_session\_data\_dir) | The path where to store files with the session data | `string` | n/a | yes |
| <a name="input_ssh_nodes_key_path"></a> [ssh\_nodes\_key\_path](#input\_ssh\_nodes\_key\_path) | The path, relative to the `session_data_dir`, to store the SSH key pair for the OKE worker nodes | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCI Tenancy ID | `string` | n/a | yes |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_bastion_ocids"></a> [bastion\_ocids](#output\_bastion\_ocids) | The Bastion OCIDs | <pre>{<br/>  "control_plane": "ocid1.bastion.oc1.eu-frankfurt-1.amaaaaaa2un2xg5chceeg7zawourh0ybm4735f01n9zl6th5mz4p2264k4x3",<br/>  "workers": {<br/>    "eu-frankfurt-1-ad-1": "ocid1.bastion.oc1.eu-frankfurt-1.amaaaaaatl59rjr0x9qe4c3bbjktxac34iy1ern22tux7jqzbvgowkkutf2h",<br/>    "eu-frankfurt-1-ad-2": "ocid1.bastion.oc1.eu-frankfurt-1.amaaaaaaoe110rd48phjoxsj9oossvo0qxwqdkeql4amj1qip6jvtu4to6cj"<br/>  }<br/>}</pre> | no |
| <a name="output_oke_compartment_ocid"></a> [oke\_compartment\_ocid](#output\_oke\_compartment\_ocid) | The OKE compartmnent's OCID | `"ocid1.compartment.oc1..aaaaaaaap9id58ahum3bensydeksqv4aie2v60lm0z4fu4y7yox3gamt5fa0"` | no |
| <a name="output_oke_external_secrets_key_ocid"></a> [oke\_external\_secrets\_key\_ocid](#output\_oke\_external\_secrets\_key\_ocid) | The key ID for the OKE ExternalSecrets encryption key | `"ocid1.key.oc1.eu-frankfurt-1.ent2pnqxaabs2.up5va3cmyxrl66bqbjkyzs04qj8x7tbwx7rvv2cr6elhd6394xb4hlp8d52v"` | no |
| <a name="output_oke_node_pool_ocid"></a> [oke\_node\_pool\_ocid](#output\_oke\_node\_pool\_ocid) | The OKE node pool's ID | `"ocid1.nodepool.oc1.eu-frankfurt-1.aaaaaaaa6iic3qcpq6rr0yzaioeui6gmpmzhw4f06qplmrssctgg32bfhl4u"` | no |
| <a name="output_oke_vault_ocid"></a> [oke\_vault\_ocid](#output\_oke\_vault\_ocid) | The OCID of the OKE Vault | `"ocid1.vault.oc1.eu-frankfurt-1.ent2pnqxaabs2.qeuwa56wsc513q7yjjqosnt4d4266puk1qtthids49v9kcoza5nvnvyjptg1"` | no |
<!-- END_TF_DOCS -->
