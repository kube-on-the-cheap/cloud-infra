variable "ssh_nodes_key_path" {
  description = "The path, relative to the session_data_dir, to read the SSH key for the OKE worker nodes"
  type        = string
}

resource "local_file" "session_script" {
  for_each = oci_bastion_session.oke_worker_access

  content = templatefile("${path.module}/templates/worker_node_session_access.sh.tftpl", {
    region                                     = var.region
    bastion_user_name                          = each.value.id
    ssh_session_key_path                       = var.ssh_public_key == "" ? one(local_sensitive_file.pvt_session_key.*.filename) : ""
    ssh_node_key_path                          = "${local.workers_session_data_dir}/${var.ssh_nodes_key_path}"
    target_resource_operating_system_user_name = one(each.value.target_resource_details.*.target_resource_operating_system_user_name)
    target_resource_id                         = one(each.value.target_resource_details.*.target_resource_id)
    target_resource_private_ip_address         = one(each.value.target_resource_details.*.target_resource_private_ip_address)
    session_ttl                                = each.value.session_ttl_in_seconds
  })
  filename        = "${local.workers_session_data_dir}/open_bastion_proxy_session_${each.key}.sh"
  file_permission = 0775
}

resource "local_file" "session_access_info" {
  content = templatefile("${path.module}/templates/README.mdown.tftpl", {
    session_data_dir     = var.session_data_dir
    session_script_paths = toset([for script in local_file.session_script : script.filename])
  })
  filename = "${local.workers_session_data_dir}/README.mdown"
}
