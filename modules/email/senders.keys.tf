resource "oci_identity_customer_secret_key" "sender_secret_key" {
  display_name = "Access Key for sender user to deliver emails through API calls"
  user_id      = oci_identity_user.sender.id
}

resource "oci_identity_smtp_credential" "sender_smtp_credential" {
  #Required
  description = "Credentials for sender user to deliver emails through SMTP."
  user_id     = oci_identity_user.sender.id
}

output "smtp_credentials" {
  sensitive = true
  value = {
    (oci_identity_user.sender.name) : {
      "username" : oci_identity_smtp_credential.sender_smtp_credential.username,
      "password" : oci_identity_smtp_credential.sender_smtp_credential.password
    }
  }
}
