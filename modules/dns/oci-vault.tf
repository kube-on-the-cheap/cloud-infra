variable "oke_compartment_id" {
  description = "The OCID of the compartment to create the OKE resources in"
  type        = string
}

variable "externalsecrets_key_id" {
  description = "The OCID of the OKE ExternalSecrets encryption key"
  type        = string
}

variable "externalsecrets_vault_id" {
  description = "The OCID of the vault containing the OKE ExternalSecrets encryption key"
  type        = string
}

variable "do_token_zone_mgmt" {
  description = "The DigitalOcean API token to use for the ExternalDNS provider"
  type        = string
  sensitive   = true
}

variable "do_token_zone_mgmt_expiry_date" {
  description = "The date the DigitalOcean API token expires, in RFC 3339 format (2017-11-22T01:00:00Z)"
  type        = string
  validation {
    condition     = can(provider::time::rfc3339_parse(var.do_token_zone_mgmt_expiry_date))
    error_message = "The do_token_expiry_date must be a valid datetime in the RFC 3339 format (2017-11-22T01:00:00Z)"
  }
  validation {
    condition     = timecmp(var.do_token_zone_mgmt_expiry_date, timestamp()) == 1
    error_message = "The do_token_expiry_date must be in the future."
  }
}

resource "oci_vault_secret" "do_zone_mgmt" {
  compartment_id = var.oke_compartment_id
  key_id         = var.externalsecrets_key_id
  vault_id       = var.externalsecrets_vault_id

  secret_name = "DigitalOceanZoneManagement"
  description = "The DigitalOcean API token to use for the zone management"

  # freeform_tags = {"Department"= "Finance"}
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.do_token_zone_mgmt)
    name         = "do_token"
    stage        = "CURRENT" # INFO: can be CURRENT or PENDING
  }
  secret_rules {
    rule_type                                     = "SECRET_EXPIRY_RULE"
    is_secret_content_retrieval_blocked_on_expiry = true
    time_of_absolute_expiry                       = var.do_token_zone_mgmt_expiry_date
  }
}

output "do_token" {
  value = {
    secret_name = oci_vault_secret.do_zone_mgmt.secret_name
    secret_key  = one(oci_vault_secret.do_zone_mgmt.secret_content.*.name)
  }
}
