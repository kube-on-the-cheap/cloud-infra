variable "session_data_dir" {
  description = "The path where to store files with the session data"
  type        = string
}

locals {
  workers_session_data_dir = "${var.session_data_dir}/workers"
}
