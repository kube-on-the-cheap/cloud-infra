terraform {
  source = "../../..//modules/zitadel"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

locals {
  google_oauth = yamldecode(sops_decrypt_file("./google-oauth.sops.yaml"))
  # users.sops.yaml is SOPS-encrypted with the original YAML wrapped under a
  # top-level `data:` key (so SOPS doesn't leak the map structure / usernames
  # via cleartext YAML keys). One yamldecode parses the SOPS output; .data
  # then exposes the original users map.
  users_data = yamldecode(sops_decrypt_file("./users.sops.yaml")).data
}

inputs = {
  zitadel_domain           = "auth.cloud.blacksd.tech"
  zitadel_jwt_profile_json = sops_decrypt_file("./zitadel-key.sops.json")
  google_client_id         = local.google_oauth.client_id
  google_client_secret     = local.google_oauth.client_secret
  users                    = local.users_data.users
}
