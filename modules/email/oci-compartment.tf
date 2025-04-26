# Resources
resource "oci_identity_compartment" "email" {
  compartment_id = var.tenancy_ocid
  name           = "email"
  description    = "email resource compartment"
  # defined_tags   = var.compartment_tags.defined
  # freeform_tags  = var.compartment_tags.freeform

  # lifecycle {
  #   ignore_changes = [
  #     defined_tags
  #   ]
  # }

}

data "oci_email_configuration" "this" {
  compartment_id = var.tenancy_ocid
}

locals {
  assembled_endpoints = {
    "http" : {
      "endpoint" : data.oci_email_configuration.this.http_submit_endpoint
    },
    "smtp" : {
      "endpoint" : data.oci_email_configuration.this.smtp_submit_endpoint
    }
  }
}

# Outputs
output "email_submission_endpoints" {
  description = "The addresses where to send emails."
  value       = local.assembled_endpoints
}
