# Terraform Config
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~>7.27"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.21.0"
    }
  }
  backend "gcs" {}
}

# Variables
variable "tenancy_ocid" {
  type        = string
  description = "The OCI Tenancy ID"
}

variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to use"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region the project is located in"
}

variable "gcp_billing_account_name" {
  type        = string
  description = "The billing account name with the payent info"
}

# Data Sources
data "google_billing_account" "this" {
  display_name = var.gcp_billing_account_name
  open         = true
}

# Providers
provider "oci" {
}

# TODO: make all of this with a ServiceAccount and proper permissions
#
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  # impersonate_service_account = "terragrunt@kube-on-the-cheap.iam.gserviceaccount.com"
}

provider "google" {
  alias = "billing"

  # For setting the specific billing usage header
  billing_project       = var.gcp_project_id
  user_project_override = true

  # impersonate_service_account = "terragrunt@kube-on-the-cheap.iam.gserviceaccount.com"
}
