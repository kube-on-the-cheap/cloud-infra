data "authentik_property_mapping_provider_scope" "openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_property_mapping_provider_scope" "profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_property_mapping_provider_scope" "email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

resource "random_id" "grimmory_client_id" {
  byte_length = 20
}

resource "authentik_provider_oauth2" "grimmory" {
  name               = "Grimmory"
  client_id          = random_id.grimmory_client_id.hex
  client_type        = "public"
  authorization_flow = data.authentik_flow.authorization.id
  invalidation_flow  = data.authentik_flow.invalidation.id

  allowed_redirect_uris = [
    {
      matching_mode     = "strict"
      url               = "https://library.homelab.blacksd.tech/oauth2-callback"
      redirect_uri_type = "authorization"
    },
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.email.id,
  ]

  sub_mode                   = "user_username"
  include_claims_in_id_token = true
}

resource "authentik_application" "grimmory" {
  name              = "Grimmory"
  slug              = "grimmory"
  protocol_provider = authentik_provider_oauth2.grimmory.id
}

output "grimmory_client_id" {
  description = "Client ID for the Authentik-side Grimmory OIDC application. Read with `terragrunt output -raw grimmory_client_id`. Not wired into Grimmory yet — the app continues using the Zitadel client until a separate apps-repo PR cuts it over."
  value       = authentik_provider_oauth2.grimmory.client_id
  sensitive   = true
}

output "grimmory_issuer_url" {
  description = "OIDC issuer URL for the Authentik-side Grimmory application. Paste into Grimmory Settings → OIDC alongside `grimmory_client_id`. The discovery document lives at `<issuer>/.well-known/openid-configuration`. Read with `terragrunt output -raw grimmory_issuer_url`."
  value       = format("%s/application/o/%s/", trimsuffix(var.authentik_url, "/"), authentik_application.grimmory.slug)
}
