variable "ssh_public_key" {
  type        = string
  description = "The SSH public key, in OpenSSH format. If not provided, an ephemeral key will be generated for this session."
  default     = ""
}

resource "time_rotating" "session_expire" {
  rotation_minutes = local.session_ttl_in_seconds / 60
}

resource "tls_private_key" "session_key" {
  count = var.ssh_public_key == "" ? 1 : 0

  algorithm   = "ECDSA"
  ecdsa_curve = "P384"

  lifecycle {
    replace_triggered_by = [
      time_rotating.session_expire
    ]
  }
}

resource "local_file" "pub_session_key" {
  count = var.ssh_public_key == "" ? 1 : 0

  content              = one(tls_private_key.session_key.*.public_key_openssh)
  filename             = "${local.workers_session_data_dir}/.ssh/bastion-access-key.pub"
  file_permission      = 0600
  directory_permission = 0700
}

resource "local_sensitive_file" "pvt_session_key" {
  count = var.ssh_public_key == "" ? 1 : 0

  content              = one(tls_private_key.session_key.*.private_key_openssh)
  filename             = "${local.workers_session_data_dir}/.ssh/bastion-access-key"
  file_permission      = 0600
  directory_permission = 0700
}
