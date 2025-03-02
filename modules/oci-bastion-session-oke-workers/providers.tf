# Terraform Config
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.23.0"
    }
  }
  backend "gcs" {}
}

# Variables
variable "region" {
  type        = string
  description = "The OCI region name"
}

# Providers
provider "oci" {
}
