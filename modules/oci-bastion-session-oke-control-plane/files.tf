locals {
  proxy_port = 8000
}

resource "local_file" "session_script" {
  content = templatefile("${path.module}/templates/open_socks5_proxy_session.sh.tftpl", {
    region               = var.region
    proxy_port           = local.proxy_port
    ssh_username         = oci_bastion_session.oke_control_plane_access.bastion_user_name
    ssh_session_key_path = one(local_sensitive_file.pvt_session_key.*.filename)
    session_ttl          = oci_bastion_session.oke_control_plane_access.session_ttl_in_seconds
  })
  filename        = "${local.control_plane_session_data_dir}/open_bastion_proxy_session.sh"
  file_permission = 0775
}

resource "local_file" "session_access_info" {
  content = templatefile("${path.module}/templates/README.mdown.tftpl", {
    proxy_port          = local.proxy_port
    session_script_path = local_file.session_script.filename
    session_ttl         = oci_bastion_session.oke_control_plane_access.session_ttl_in_seconds
    session_data_dir    = var.session_data_dir
  })
  filename = "${local.control_plane_session_data_dir}/README.mdown"
}

resource "local_file" "session_env_vars" {
  content = templatefile("${path.module}/templates/envrc.tftpl", {
    proxy_port = local.proxy_port
  })
  filename = "${local.control_plane_session_data_dir}/.envrc"
}
