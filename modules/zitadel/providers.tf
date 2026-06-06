terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "~> 2.12"
    }
  }
  backend "gcs" {}
}

provider "zitadel" {
  domain           = var.zitadel_domain
  jwt_profile_json = var.zitadel_jwt_profile_json
}
