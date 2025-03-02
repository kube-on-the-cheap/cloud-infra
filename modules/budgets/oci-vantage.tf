locals {
  vantage_public_key   = <<EOF
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAroI4gzSZrzKxxTpaWhFu
77uv/rRgT1MxCexEjhgmv+AR3MW3Hq50/pkLP+XHnYSNY81qgJ3zeSymxEaDoI4V
Eh+jHZF8iDyQwuc6O8zDtOfras8xchSe9z1arLYv4scMb8azviqWrJbqWP/a7HUK
a7G6TjIZXZTuPfWK0Ramd/qlKd3nobJj31zEysB9uZIENlB/FvRBM4ghgyJBGdfn
LnEzNCmWuo690sNLWzCvzGpcD0taShAB56Raz7oQOwFFe9Xxtks0+J3gAv2OpBGd
RcRUDP2H9cAEOLM50U0vMICIO8fBk65grDekhbME4y108KWR+P5Z6Kq4Wpf9yVD+
TwIDAQAB
-----END PUBLIC KEY-----
EOF
  vantage_tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq"
}

resource "oci_identity_user" "vantage" {
  compartment_id = var.tenancy_ocid
  description    = "vantage.sh user"
  name           = "vantage"
  email          = "no-reply@vantage.sh"
}

resource "oci_identity_group" "vantage" {
  compartment_id = var.tenancy_ocid
  description    = "vantage.sh group"
  name           = "vantage"
}

resource "oci_identity_user_group_membership" "vantage" {
  group_id = oci_identity_group.vantage.id
  user_id  = oci_identity_user.vantage.id
}

resource "oci_identity_api_key" "vantage" {
  key_value = local.vantage_public_key
  user_id   = oci_identity_user.vantage.id
}

resource "oci_identity_policy" "vantage" {
  compartment_id = var.tenancy_ocid
  description    = "Allow vantage.sh access"
  name           = "vantage-read-only"
  statements = [
    "define tenancy reporting as ${local.vantage_tenancy_ocid}",
    "endorse group ${oci_identity_group.vantage.name} to read objects in tenancy reporting"
  ]
}

output "oci_vantage_setup_info" {
  description = "Use these informations for vantage.sh setup"
  value = {
    vantage_tenancy_id = var.tenancy_ocid
    vantage_user_id    = oci_identity_user.vantage.id
  }
}
