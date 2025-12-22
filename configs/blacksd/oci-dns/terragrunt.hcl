terraform {
  source = "../../..//modules/oci-dns"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

dependency "email" {
  config_path  = "../email"
  mock_outputs = jsondecode(file("../email/output-values.mock.json"))
}

inputs = {
  # Cloudflare zone
  domain_name = "blacksd.tech"

  # DigitalOcean project
  project_name = "Kube, on the cheap"

  # Cloud domain
  # cloud_domain_name = "cloud.blacksd.tech"

  # Email domain
  # email_subdomain_name = "email.cloud.blacksd.tech"
  email_dkim_cname = dependency.email.outputs.dkim_cname
  email_spf_txt    = dependency.email.outputs.spf_txt
}
