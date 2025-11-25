# Terraform Config
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~>7.27"
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
