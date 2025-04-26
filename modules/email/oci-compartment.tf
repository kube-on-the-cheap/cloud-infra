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

# Outputs
output "email_submission_endpoints" {
  description = "The addresses where to send emails."
  value = {
    "http" : data.oci_email_configuration.this.http_submit_endpoint,
    "smtp" : data.oci_email_configuration.this.smtp_submit_endpoint
  }
}
