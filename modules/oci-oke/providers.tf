# Terraform Config
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.26.0"
    }
    # sops = {
    #   source = "lokkersp/sops"
    #   version = "0.6.10"
    # }
  }
  backend "gcs" {}
}

# Variables
variable "tenancy_ocid" {
  type        = string
  description = "The OCI Tenancy ID"
}

variable "region" {
  type        = string
  description = "The OCI region name"
}

# Providers
provider "oci" {
}

# provider "sops" {
#   # Configuration options
# }
