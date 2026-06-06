terraform {
  source = "../../..//modules/zitadel"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

inputs = {
  zitadel_domain           = "auth.cloud.blacksd.tech"
  zitadel_jwt_profile_json = sops_decrypt_file("./zitadel-key.sops.json")
}
