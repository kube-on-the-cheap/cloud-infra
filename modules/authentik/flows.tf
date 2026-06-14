data "authentik_flow" "source_authentication" {
  slug = "default-source-authentication"
}

data "authentik_flow" "source_enrollment" {
  slug = "default-source-enrollment"
}

data "authentik_flow" "authorization" {
  # Explicit consent (not implicit) so the flow includes a consent stage —
  # required by Authentik 2026.x when the client requests offline_access
  # (refresh tokens). Implicit-consent flows reject offline_access as
  # "otherwise malformed".
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_flow" "invalidation" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_flow" "authentication" {
  slug = "default-authentication-flow"
}
