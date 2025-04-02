variable "oke_k8s_workers_version" {
  description = "The Kubernetes version to run on the workers"
  type        = string
}

variable "ssh_nodes_key_path" {
  description = "The path, relative to the `session_data_dir`, to store the SSH key pair for the OKE worker nodes"
  type        = string
}

# https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm#freetier_topic_Always_Free_Resources_Infrastructure
locals {
  oke_node_shape = "VM.Standard.A1.Flex"
  oke_node_images = [for i in data.oci_containerengine_node_pool_option.this.sources : i if(
    i.source_type == "IMAGE" &&
    strcontains(i.source_name, "Oracle-Linux-8.10") &&
    strcontains(i.source_name, "aarch64") &&
    strcontains(i.source_name, var.oke_k8s_workers_version)
  )]
}

data "oci_containerengine_node_pool_option" "this" {
  compartment_id      = oci_identity_compartment.oke.id
  node_pool_option_id = oci_containerengine_cluster.freeloader.id
}

resource "oci_identity_policy" "allow_oke_nodes_update_self" {
  compartment_id = oci_identity_compartment.oke.id

  name        = "allow_${oci_identity_dynamic_group.all_oke_workers.name}_update_self"
  description = "Policy to allow each worker node of OKE to update only itself."
  statements = [
    "allow dynamic-group ${oci_identity_dynamic_group.all_oke_workers.name} to use instance in compartment id ${oci_identity_compartment.oke.id} where request.instance.id=target.instance.id"
  ]
}

resource "tls_private_key" "node_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "oci_containerengine_node_pool" "dishonoredcheques" {
  compartment_id = oci_identity_compartment.oke.id

  cluster_id = oci_containerengine_cluster.freeloader.id
  name       = "dishonoredcheques"

  # initial_node_labels {
  #     #Optional
  #     key = var.node_pool_initial_node_labels_key
  #     value = var.node_pool_initial_node_labels_value
  # }
  kubernetes_version = format("v%s", var.oke_k8s_workers_version)
  node_config_details {

    dynamic "placement_configs" {
      for_each = toset(keys(local.availability_domains))
      content {
        availability_domain = placement_configs.key
        subnet_id           = oci_core_subnet.ad_nodes[placement_configs.key].id
      }
    }
    size = 2

    kms_key_id = oci_kms_key.oke_node_encryption_key.id
    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = 31 # maximum allowed for the shape VM.Standard.A1.Flex
      pod_subnet_ids    = [oci_core_subnet.regional_pods.id]
      # pod_nsg_ids = var.node_pool_node_config_details_node_pool_pod_network_option_details_pod_nsg_ids
    }
    # defined_tags = {"Operations.CostCenter"= "42"}
    # freeform_tags = {"Department"= "Finance"}
    nsg_ids = [
      oci_core_network_security_group.oke_workers.id
    ]
  }
  node_metadata = {
    areLegacyImdsEndpointsDisabled = "true"
    # https://blogs.oracle.com/cloud-infrastructure/post/container-engine-for-kubernetes-custom-worker-node-startup-script-support
    # https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengusingcustomcloudinitscripts.htm
    user_data = base64encode(<<-EOT
#!/bin/bash
# Update the instance config to enable the Bastion plugin
dnf install --assumeyes python36-oci-cli
echo '{"areAllPluginsDisabled":false,"isManagementDisabled":false,"isMonitoringDisabled":false,"pluginsConfig":[{"desiredState":"ENABLED","name":"Bastion"}]}' > ./agent_config.json
export OCI_CLI_AUTH=instance_principal
oci compute instance update --instance-id $(oci-instanceid) --agent-config file://./agent_config.json --force
# Enable persistent journal logging
mkdir -p /var/log/journal
# Continue with the OKE provisioning
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh
EOT
    )
  }
  node_eviction_node_pool_settings {
    eviction_grace_duration = "PT1H"
  }
  node_pool_cycling_details {
    is_node_cycling_enabled = false
    maximum_surge           = 0
    maximum_unavailable     = 2
  }
  node_shape = local.oke_node_shape
  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }
  node_source_details {
    image_id                = local.oke_node_images[0].image_id
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = 50 # NOTE: Free Tier gives 200 GB of volume storage, so we can use the 50 GB minimum for boot volume and the rest with the provisioned `oci-bv` StorageClass. https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm#blockvolume
  }
  ssh_public_key = tls_private_key.node_key.public_key_openssh

  depends_on = [
    oci_identity_policy.allow_oke_nodes_update_self
  ]
}

output "oke_node_pool_ocid" {
  description = "The OKE node pool's ID"
  value       = oci_containerengine_node_pool.dishonoredcheques.id
}

resource "local_file" "nodes_pub_key" {
  content              = tls_private_key.node_key.public_key_openssh
  filename             = "${var.session_data_dir}/workers/${var.ssh_nodes_key_path}.pub"
  file_permission      = 0644
  directory_permission = 0700
}

resource "local_sensitive_file" "nodes_pvt_key" {
  content              = tls_private_key.node_key.private_key_openssh
  filename             = "${var.session_data_dir}/workers/${var.ssh_nodes_key_path}"
  file_permission      = 0600
  directory_permission = 0700
}
