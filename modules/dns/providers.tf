# Terraform Config
terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~>0.13"
    }
    oci = {
      source  = "oracle/oci"
      version = "~>6.26"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.49"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~>5.1"
    }
  }
  backend "gcs" {}
}

# Variables
# variable "tenancy_ocid" {
#   type        = string
#   description = "The OCI Tenancy ID"
# }

# variable "region" {
#   type        = string
#   description = "The OCI region name"
# }

# Providers
provider "oci" {
}

provider "digitalocean" {
}

provider "cloudflare" {
}
