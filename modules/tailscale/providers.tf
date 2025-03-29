terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~>0.18"
    }
    oci = {
      source  = "oracle/oci"
      version = "~>6.26"
    }
  }
  backend "gcs" {}
}
