resource "oci_identity_customer_secret_key" "sender_secret_key" {
  display_name = "Access Key for sender user to deliver emails through API calls"
  user_id      = oci_identity_user.sender.id
}

resource "oci_identity_smtp_credential" "sender_smtp_credential" {
  description = "Credentials for sender user to deliver emails through SMTP."
  user_id     = oci_identity_user.sender.id
}

locals {
  assembled_credentials = {
    "smtp" : {
      "username" : oci_identity_smtp_credential.sender_smtp_credential.username,
      "password" : oci_identity_smtp_credential.sender_smtp_credential.password
    },
    "http" : {
      "access_key_id" : oci_identity_customer_secret_key.sender_secret_key.id
      "secret_access_key" : oci_identity_customer_secret_key.sender_secret_key.key
    }
  }
}

resource "oci_vault_secret" "sender_credentials" {
  compartment_id = oci_identity_compartment.email.id
  key_id         = oci_kms_key.email_encription_key.id
  vault_id       = oci_kms_vault.this.id

  secret_name = "EmailCredentialsSender"
  description = "Credentials for the user 'sender' to deliver emails with SMTP and APIs."

  # freeform_tags = {"Department"= "Finance"}
  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode(
      { for proto in keys(local.assembled_credentials) :
        proto => merge(
          local.assembled_credentials[proto],
          local.assembled_endpoints[proto]
        )
      }
    ))
    name  = "email_credentials"
    stage = "CURRENT" # INFO: can be CURRENT or PENDING
  }
}

output "email_submission_credentials_user_sender" {
  sensitive   = true
  description = "Credentials to use for submitting emails with user 'sender'."
  value       = local.assembled_credentials
}
