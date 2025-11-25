terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~>0.18"
    }
    oci = {
      source  = "oracle/oci"
      version = "~>7.27"
    }
  }
  backend "gcs" {}
}
