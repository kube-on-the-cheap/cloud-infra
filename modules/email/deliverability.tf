# DKIM

# INFO: https://docs.oracle.com/en-us/iaas/Content/Email/Tasks/configure-dkim-using-the-console.htm

resource "tls_private_key" "dkim_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "random_string" "selector" {
  length  = 6
  special = false
  upper   = false
}

resource "oci_email_dkim" "this" {
  email_domain_id = oci_email_email_domain.this.id
  name            = format("trnsct-%s", random_string.selector.result)
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
