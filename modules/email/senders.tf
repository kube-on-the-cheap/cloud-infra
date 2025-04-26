resource "oci_email_sender" "notifications" {
  compartment_id = oci_identity_compartment.email.id
  email_address  = format("notifications@%s", var.email_domain_name)
  # defined_tags = {"Operations.CostCenter"= "42"}
  # freeform_tags = {"Department"= "Finance"}
}

resource "oci_email_sender" "do_not_reply" {
  compartment_id = oci_identity_compartment.email.id
  email_address  = format("do-not-reply@%s", var.email_domain_name)
  # defined_tags = {"Operations.CostCenter"= "42"}
  # freeform_tags = {"Department"= "Finance"}
}

resource "oci_identity_user" "mailer" {
  compartment_id = var.tenancy_ocid
  description    = "Robot user to send emails via SMTP and/or API calls."
  name           = "mailer"

  email = format("mailer@%s", var.email_domain_name)
  # freeform_tags = { "IAM-UserInfo.UserType" = "robot" }
}

resource "oci_identity_group" "sender_group" {
  compartment_id = var.tenancy_ocid
  description    = "Group of all users allowed to send emails via SMTP and/or API calls."
  name           = "email_sender_group"

}

resource "oci_identity_user_group_membership" "test_user_group_membership" {
  #Required
  group_id = oci_identity_group.sender_group.id
  user_id  = oci_identity_user.mailer.id
}

resource "oci_identity_policy" "allow_sender_smtp" {
  compartment_id = var.tenancy_ocid

  name        = "allow_group_sender_use_emails"
  description = "Policy to allow group ${oci_identity_group.sender_group.name} to send emails with approved senders"
  statements = [
    "Allow group ${oci_identity_group.sender_group.name} to use email-family in compartment id ${oci_identity_compartment.email.id} where any { target.approved-sender.id ='${oci_email_sender.notifications.id}', target.approved-sender.id ='${oci_email_sender.do_not_reply.id}' }"
  ]

  # freeform_tags = { "IAM-UserInfo.UserType" = "robot" }
}
