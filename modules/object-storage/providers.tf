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
