
variable "email_subdomain_name" {
  type        = string
  description = "The email domain name."
}

resource "oci_email_email_domain" "this" {
  compartment_id = oci_identity_compartment.email.id
  name           = var.email_subdomain_name

  # defined_tags = {"Operations.CostCenter"= "42"}
  description = "The email domain used to send transactional notification."
  # domain_verification_id = oci_email_domain_verification.test_domain_verification.id
  # freeform_tags = {"Department"= "Finance"}
}


resource "oci_identity_policy" "allow_email_tenancy" {
  compartment_id = var.tenancy_ocid

  name        = "allow_email_service_tenancy"
  description = "Policy to allow email service to work in tenancy."
  statements = [
    "Allow service EmailDelivery to read email-configuration in tenancy",
  ]
}
