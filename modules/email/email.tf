
variable "email_domain_name" {
  type        = string
  description = "The email domain name."
}

resource "oci_email_email_domain" "this" {
  compartment_id = oci_identity_compartment.email.id
  name           = var.email_domain_name

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

# DKIM

# INFO: https://docs.oracle.com/en-us/iaas/Content/Email/Tasks/configure-dkim-using-the-console.htm

resource "tls_private_key" "dkim_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_email_dkim" "this" {
  email_domain_id = oci_email_email_domain.this.id
  name            = "trnsct-202504"
  description     = "Configuration for transactional email"
  private_key     = tls_private_key.dkim_key.private_key_pem
}

output "dkim_cname" {
  value = {
    selector = oci_email_dkim.this.name
    dst      = format("%s.", oci_email_dkim.this.cname_record_value)
  }
  description = "The CNAME to configure to set up DKIM in the domain."
}

# SPF

# INFO: https://docs.oracle.com/en-us/iaas/Content/Email/Tasks/configurespf.htm

# NOTE: "fra1.rp.oracleemaildelivery.com" also works
#       format("%s%s", substr(split("-",var.region)[1],0,3),split("-",var.region)[2])

output "spf_txt" {
  value       = "v=spf1 include:${split("-", var.region)[0]}.rp.oracleemaildelivery.com ~all"
  description = "The TXT record to configure to set up SPF in the domain."
}
