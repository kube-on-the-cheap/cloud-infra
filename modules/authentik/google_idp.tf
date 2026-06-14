resource "authentik_source_oauth" "google" {
  name                = "Google"
  slug                = "google"
  provider_type       = "google"
  consumer_key        = var.google_client_id
  consumer_secret     = var.google_client_secret
  authentication_flow = data.authentik_flow.source_authentication.id
  enrollment_flow     = data.authentik_flow.source_enrollment.id
  user_matching_mode  = "email_link"

  # Without this, the source exists but the identification stage doesn't render
  # the per-source button. This is Authentik's equivalent of wiring
  # zitadel_default_login_policy.idps in the Zitadel module.
  promoted = true
}
