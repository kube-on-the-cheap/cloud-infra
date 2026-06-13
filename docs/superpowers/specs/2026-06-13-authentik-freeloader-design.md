# Authentik on freeloader — Terraform module

**Status:** Design approved 2026-06-13.

**Goal:** Mirror the existing `modules/zitadel/` + `configs/blacksd/zitadel/` setup for the Authentik instance deployed on the freeloader cluster (`login.cloud.blacksd.tech`). Manage the same human users, the same four group buckets, the same Google IdP integration, and a parallel OIDC client for Grimmory — all from Terraform.

## Scope

In scope:

- New `modules/authentik/` Terraform module targeting the `goauthentik/authentik` provider against the Authentik chart already deployed on freeloader.
- New `configs/blacksd/authentik/` terragrunt config that decrypts SOPS-encrypted credentials and feeds the module.
- Four `authentik_group` resources (`users`, `admins`, `grownups`, `kids`) matching the role buckets used by the Zitadel module.
- Human users from a fresh copy of `users.sops.yaml`, with group memberships computed from the same four membership lists.
- Google OAuth source (`authentik_source_oauth { provider_type = "google" }`) with email-based account linking, mirroring `zitadel_idp_google` semantics.
- Grimmory as an `authentik_provider_oauth2` (public/PKCE) + `authentik_application`, **in parallel** with the existing Zitadel client. Grimmory's app-side runtime config is untouched.

Out of scope:

- Cutting Grimmory's runtime over to Authentik (separate apps-repo follow-up).
- A flat `groups` claim on the id_token. Default scopes (`openid`, `profile`, `email`) only — the groups-claim property mapping is deferred to a future spec.
- Decommissioning the Zitadel module or the duplicated `users.sops.yaml`. Both Authentik and Zitadel coexist until one is explicitly retired.
- MFA, password policies, custom login/enrollment flows.
- Any change to the Authentik Helm release, HTTPRoute, or Postgres cluster.

## Why mirror, instead of share

The Zitadel and Authentik data models don't translate 1:1, so a literal port wouldn't work even if we wanted one:

| Concept | Zitadel | Authentik |
|---|---|---|
| Multi-tenancy | Org (`local.org_id` discovered from `zitadel_orgs`) | No org concept — flat instance |
| Project | `zitadel_project "homelab"` groups apps + roles | No equivalent; applications stand alone |
| Roles | Per-project `zitadel_project_role` | No project-roles; groups are the access primitive |
| Role grants | `zitadel_user_grant` per (user, project) with `role_keys` | `groups` list directly on `authentik_user` |
| Groups claim | Custom JS action on `pre-userinfo` flow | First-class via `authentik_property_mapping_provider_scope` (deferred here) |
| Google IdP | `zitadel_idp_google` + flip on `zitadel_default_login_policy.idps` | `authentik_source_oauth` (`provider_type = "google"`); sources auto-surface on the login flow |
| Provider bootstrap | Service-user JWT key | API token from initial admin user |

Concretely: `project.tf`, `project_roles.tf`, `user_grants.tf`, and `groups_action.tf` from the Zitadel module have no counterparts. Group assignment moves onto the user resource itself.

## Architecture

### Module layout — `modules/authentik/`

```
providers.tf       # goauthentik/authentik ~> 2024.0; hashicorp/random ~> 3.6; backend "gcs" {}
variables.tf       # authentik_url, authentik_token, google_*, users, users_group, admins, grownups, kids
main.tf            # locals { managed_by = "cloud-infra/modules/authentik" }
flows.tf           # data sources for the four default flows used downstream
google_idp.tf      # authentik_source_oauth.google
groups.tf          # four authentik_group resources
users.tf           # random_password.user_initial + authentik_user.users
grimmory.tf        # authentik_provider_oauth2 + authentik_application + grimmory_client_id output
README.md          # mirrors modules/zitadel/README.md
```

No `project.tf`, no `project_roles.tf`, no `user_grants.tf`, no `groups_action.tf` — those concepts don't exist in Authentik.

### Config layout — `configs/blacksd/authentik/`

```
terragrunt.hcl                  # source = "../../..//modules/authentik"
users.sops.yaml                 # fresh copy of configs/blacksd/zitadel/users.sops.yaml
google-oauth.sops.yaml          # reuses the same Google OAuth client_id / client_secret
authentik-token.sops.yaml       # API token for the Terraform-owned admin user
```

The duplicated `users.sops.yaml` is an accepted, short-term drift cost. One of {Zitadel, Authentik} will be retired before the divergence matters; the other config dir becomes the sole roster.

### Providers

```hcl
terraform {
  required_providers {
    authentik = { source = "goauthentik/authentik", version = "~> 2024.0" }
    random    = { source = "hashicorp/random",     version = "~> 3.6" }
  }
  backend "gcs" {}
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
}
```

### Variables

```hcl
variable "authentik_url" {
  type    = string
  default = "https://login.cloud.blacksd.tech"
}

variable "authentik_token" {
  type      = string
  sensitive = true
}

variable "google_client_id" {
  type      = string
  sensitive = true
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "users" {
  sensitive = true
  type = map(object({
    first_name         = string
    last_name          = string
    email              = string
    display_name       = optional(string)
    nick_name          = optional(string)
    preferred_language = optional(string)
  }))
}

variable "users_group" {
  type      = list(string)
  default   = []
  sensitive = true
}

variable "admins" {
  type      = list(string)
  default   = []
  sensitive = true
}

variable "grownups" {
  type      = list(string)
  default   = []
  sensitive = true
}

variable "kids" {
  type      = list(string)
  default   = []
  sensitive = true
}
```

`nick_name` and `preferred_language` are accepted to match the Zitadel variable shape so the SOPS file is bit-for-bit reusable, but Authentik's `authentik_user` resource has no equivalent fields. They are silently ignored by the module.

### Terragrunt inputs

```hcl
terraform {
  source = "../../..//modules/authentik"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

locals {
  google_oauth    = yamldecode(sops_decrypt_file("./google-oauth.sops.yaml"))
  users_data      = yamldecode(sops_decrypt_file("./users.sops.yaml"))
  authentik_token = yamldecode(sops_decrypt_file("./authentik-token.sops.yaml")).token
}

inputs = {
  authentik_url        = "https://login.cloud.blacksd.tech"
  authentik_token      = local.authentik_token
  google_client_id     = local.google_oauth.client_id
  google_client_secret = local.google_oauth.client_secret
  users                = local.users_data.users
  users_group          = try(local.users_data.groups.users,    [])
  admins               = try(local.users_data.groups.admins,   [])
  grownups             = try(local.users_data.groups.grownups, [])
  kids                 = try(local.users_data.groups.kids,     [])
}
```

### Flow data sources — `flows.tf`

```hcl
data "authentik_flow" "source_authentication" {
  slug = "default-source-authentication"
}

data "authentik_flow" "source_enrollment" {
  slug = "default-source-enrollment"
}

data "authentik_flow" "authorization" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "invalidation" {
  slug = "default-provider-invalidation-flow"
}
```

These slugs ship with every stock Authentik install. If they aren't present (custom-flows tenant), `terragrunt plan` fails fast at data-resolution — the right failure mode for a misconfigured target.

### Groups — `groups.tf`

```hcl
resource "authentik_group" "users" {
  name = "users"
}

resource "authentik_group" "admins" {
  name = "admins"
}

resource "authentik_group" "grownups" {
  name = "grownups"
}

resource "authentik_group" "kids" {
  name = "kids"
}
```

### Users — `users.tf`

```hcl
resource "random_password" "user_initial" {
  for_each = nonsensitive(var.users)

  length           = 32
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

locals {
  user_group_ids = nonsensitive({
    for username in keys(var.users) :
    username => compact([
      contains(var.users_group, username) ? authentik_group.users.id    : null,
      contains(var.admins,      username) ? authentik_group.admins.id   : null,
      contains(var.grownups,    username) ? authentik_group.grownups.id : null,
      contains(var.kids,        username) ? authentik_group.kids.id     : null,
    ])
  })
}

resource "authentik_user" "users" {
  for_each = nonsensitive(var.users)

  username = each.key
  name     = coalesce(each.value.display_name, format("%s %s", each.value.first_name, each.value.last_name))
  email    = each.value.email
  type     = "internal"
  groups   = local.user_group_ids[each.key]
  password = random_password.user_initial[each.key].result

  lifecycle {
    ignore_changes = [password]
  }
}
```

Authentik does not expose an `is_email_verified` flag or an `initial_skip_password_change` flag on `authentik_user`. The first interactive login surfaces the default flows; tightening those (forced password change, email verification) is out of scope for this spec.

### Google IdP — `google_idp.tf`

```hcl
resource "authentik_source_oauth" "google" {
  name                = "Google"
  slug                = "google"
  provider_type       = "google"
  consumer_key        = var.google_client_id
  consumer_secret     = var.google_client_secret
  authentication_flow = data.authentik_flow.source_authentication.id
  enrollment_flow     = data.authentik_flow.source_enrollment.id
  user_matching_mode  = "email_link"
}
```

`email_link` mirrors Zitadel's `AUTO_LINKING_OPTION_EMAIL`: if an Authentik account with the same email exists, Google sign-in links to it; otherwise the enrollment flow runs. Unlike Zitadel, no separate "login policy" resource is needed — Authentik surfaces enabled sources on the default authentication flow automatically.

The Google OAuth client must list `https://login.cloud.blacksd.tech/source/oauth/callback/google/` as an authorized redirect URI. This is a manual one-time change in the Google Cloud Console, captured in the README.

### Grimmory OIDC client — `grimmory.tf`

```hcl
data "authentik_property_mapping_provider_scope" "openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_property_mapping_provider_scope" "profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

data "authentik_property_mapping_provider_scope" "email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

resource "authentik_provider_oauth2" "grimmory" {
  name               = "Grimmory"
  client_id          = "grimmory"
  client_type        = "public"
  authorization_flow = data.authentik_flow.authorization.id
  invalidation_flow  = data.authentik_flow.invalidation.id

  allowed_redirect_uris = [
    { matching_mode = "strict", url = "https://library.homelab.blacksd.tech/oauth2-callback" },
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
```

`client_type = "public"` is the Authentik equivalent of `OIDC_AUTH_METHOD_TYPE_NONE` on the Zitadel side: PKCE-only, no client secret. The OIDC discovery document is served at `https://login.cloud.blacksd.tech/application/o/grimmory/.well-known/openid-configuration`.

No `groups` claim is emitted. A future spec adds an `authentik_property_mapping_provider_scope` that flattens `request.user.ak_groups` into a `groups` array, matching the Zitadel module's `setGroupsClaim` action. Without it, Grimmory will see `openid` / `profile` / `email` claims only.

## Bootstrap & operations

Documented in `modules/authentik/README.md`, mirroring the structure of `modules/zitadel/README.md`:

1. Log into the Authentik admin UI at `https://login.cloud.blacksd.tech/if/admin/` from a permitted source IP (the admin route is gated by the existing `authentik-admin-ip-filter` SecurityPolicy).
2. Create a Terraform-owned admin account (`type: internal`, member of the built-in `authentik Admins` superuser group) and generate an API token for it.
3. Save the token to `configs/blacksd/authentik/authentik-token.sops.yaml` as `token: <value>`, then `sops --encrypt --in-place authentik-token.sops.yaml`. The repo-root `.sops.yaml` `path_regex` picks it up automatically.
4. Copy `configs/blacksd/zitadel/users.sops.yaml` to `configs/blacksd/authentik/users.sops.yaml` (decrypt, copy plaintext, re-encrypt) and `configs/blacksd/zitadel/google-oauth.sops.yaml` to `configs/blacksd/authentik/google-oauth.sops.yaml`.
5. In the Google Cloud Console, add `https://login.cloud.blacksd.tech/source/oauth/callback/google/` to the OAuth client's authorized redirect URIs.
6. `devbox shell && cd configs/blacksd/authentik && terragrunt init && terragrunt plan && terragrunt apply`.

### Verification

- Authentik admin UI → Directory → Users: every entry in `users.sops.yaml` is present, with the expected group memberships under Directory → Groups.
- Authentik admin UI → Directory → Federation & Social login: Google source present and enabled.
- `curl -s https://login.cloud.blacksd.tech/application/o/grimmory/.well-known/openid-configuration | jq .issuer` returns `https://login.cloud.blacksd.tech/application/o/grimmory/`.
- `terragrunt output -raw grimmory_client_id` prints the client ID. (Not consumed downstream yet.)

## Risks & open questions

- **Two parallel Grimmory clients.** Until the apps-repo cutover, Grimmory has OIDC clients in both Zitadel and Authentik. The Authentik one is unused at runtime, so the risk is limited to clutter and a stale-token surface if someone accidentally points Grimmory at the wrong issuer. Acceptable for the interim.
- **Reusing the same Google OAuth client.** The same `client_id` / `client_secret` are used for Zitadel and Authentik. The Google client just needs the additional Authentik callback URI in its authorized list. This is a deliberate simplification; if isolating credentials per IdP becomes desirable, splitting into two SOPS files is a one-file diff.
- **Drifting `users.sops.yaml`.** Two independently edited rosters can drift. Mitigation lives in the README: edits to either file should be propagated until one side is retired. This is explicit, time-boxed tech debt.
- **No groups claim.** Grimmory cannot authorize by role through the Authentik client until the property mapping is added. Captured as a follow-up spec, not a blocker for parity work.
- **Provider version pin.** `~> 2024.0` was the most recent stable line at the time of writing. If a newer Authentik provider release happens before apply, bump deliberately in a follow-up rather than letting `terragrunt init` float.
