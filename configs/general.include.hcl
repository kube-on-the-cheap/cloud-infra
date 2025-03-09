remote_state {
  backend      = "gcs"
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
  config = {
    bucket   = format("%s-%s", local.gcp.project_id, "3st1qzzy") # INFO: We need a globally unique bucket name, and we don't have the neat AWS get_caller_id function available for GCP
    prefix   = format("%s/terraform.tfstate", path_relative_to_include())
    project  = local.gcp.project_id
    location = local.gcp.region
  }
}

locals {
  project_details = {
    name       = "Kube, on the cheap"
    tagline    = "A lab project for the parsimonious Kubernetes administrator"
    short_form = "kube-on-the-cheap"
  }
  gcp = {
    region     = "europe-west3"
    project_id = local.project_details.short_form
  }
}

inputs = {
  project_name       = local.project_details.name
  gcp_project_id     = local.gcp.project_id
  gcp_region         = local.gcp.region
  session_data_dir   = "${get_parent_terragrunt_dir()}/../bastion-sessions"
  ssh_nodes_key_path = ".ssh/nodes_key" # INFO: This is the path to the SSH key for the OKE worker nodes; it's created in the `oci-oke` module and consumed in the `oci-oke-bastion-session-workers` module
  proxy_port         = 8000
}

terraform_version_constraint  = "~> 1.10.0"
terragrunt_version_constraint = "~> 0.71.0"
