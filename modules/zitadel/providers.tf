terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "~> 1.2"
    }
  }
  backend "gcs" {}
}

provider "zitadel" {
  domain       = var.zitadel_domain
  access_token = var.zitadel_access_token
}
