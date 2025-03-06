locals {
  services_cidr = "172.20.0.0/16"
}

variable "oke_k8s_cluster_version" {
  description = "The Kubernetes version to run in the control plane"
  type        = string
  default     = "1.31.1"
}

resource "oci_containerengine_cluster" "freeloader" {
  compartment_id = oci_identity_compartment.oke.id

  kubernetes_version = format("v%s", var.oke_k8s_cluster_version)
  name               = "freeloader"
  vcn_id             = oci_core_vcn.oke.id

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }
  # defined_tags = { "Operations.CostCenter" = "42" }
  # freeform_tags = { "Department" = "Finance" }
  endpoint_config {
    is_public_ip_enabled = false
    nsg_ids = [
      oci_core_network_security_group.k8s_api_endpoint.id
    ]
    subnet_id = oci_core_subnet.regional_control_plane.id
  }
  image_policy_config {
    is_policy_enabled = false
  }
  kms_key_id = oci_kms_key.oke_master_encryption_key.id

  options {

    kubernetes_network_config {
      services_cidr = local.services_cidr
    }

    # open_id_connect_token_authentication_config {
    #   #Required
    #   is_open_id_connect_auth_enabled = var.cluster_options_open_id_connect_token_authentication_config_is_open_id_connect_auth_enabled

    #   #Optional
    #   ca_certificate = var.cluster_options_open_id_connect_token_authentication_config_ca_certificate
    #   client_id      = oci_containerengine_client.test_client.id
    #   groups_claim   = var.cluster_options_open_id_connect_token_authentication_config_groups_claim
    #   groups_prefix  = var.cluster_options_open_id_connect_token_authentication_config_groups_prefix
    #   issuer_url     = var.cluster_options_open_id_connect_token_authentication_config_issuer_url
    #   required_claims {

    #     #Optional
    #     key   = var.cluster_options_open_id_connect_token_authentication_config_required_claims_key
    #     value = var.cluster_options_open_id_connect_token_authentication_config_required_claims_value
    #   }
    #   signing_algorithms = var.cluster_options_open_id_connect_token_authentication_config_signing_algorithms
    #   username_claim     = var.cluster_options_open_id_connect_token_authentication_config_username_claim
    #   username_prefix    = var.cluster_options_open_id_connect_token_authentication_config_username_prefix
    # }
    # open_id_connect_discovery {

    #   #Optional
    #   is_open_id_connect_discovery_enabled = var.cluster_options_open_id_connect_discovery_is_open_id_connect_discovery_enabled
    # }
    persistent_volume_config {

      #Optional
      # defined_tags  = { "Operations.CostCenter" = "42" }
      # freeform_tags = { "Department" = "Finance" }
    }
    service_lb_config {

      #Optional
      # defined_tags  = { "Operations.CostCenter" = "42" }
      # freeform_tags = { "Department" = "Finance" }
    }
    # service_lb_subnet_ids = [
    #   oci_core_subnet.regional_subnet_service_lb.id
    # ]
    service_lb_subnet_ids = [for subnet in oci_core_subnet.ad_lbs : subnet.id]

  }
  type = "BASIC_CLUSTER"

  depends_on = [
    oci_identity_policy.allow_oke_mek
  ]
}

data "oci_containerengine_cluster_kube_config" "this" {
  cluster_id = oci_containerengine_cluster.freeloader.id
  endpoint   = "PRIVATE_ENDPOINT"
}

variable "proxy_port" {
  description = "The port the SOCKS5 proxy will listen on"
  type        = number
}

locals {
  kubeconfig = yamldecode(data.oci_containerengine_cluster_kube_config.this.content)

  # INFO: apologies for the ugly expression, but this makes sure to keep any key even if there's
  #       more in the future
  cluster_with_proxy = { for k, v in one(local.kubeconfig.clusters) : k =>
    k == "cluster" ? merge(v, { proxy-url = format("socks5://127.0.0.1:%s", var.proxy_port) }) : v
  }

  # NOTE: favoring the JSON encoding over the default YAML one for the kubeconfig, as Terraform's
  #       output is atrocious, see https://github.com/hashicorp/terraform/issues/23322
  kubeconfig_with_proxy = jsonencode(
    merge(local.kubeconfig, { clusters = [local.cluster_with_proxy] })
  )
}

resource "local_file" "kubeconfig" {
  content              = local.kubeconfig_with_proxy
  filename             = "${var.session_data_dir}/control-plane/.kube/config"
  directory_permission = 0755
  file_permission      = 0600
}
