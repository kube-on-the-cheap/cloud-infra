# authentik

Terraform module for managing the self-hosted Authentik instance at
`login.cloud.blacksd.tech` (deployed on the freeloader cluster). Mirrors
`modules/zitadel/` — same users, same four group buckets, same Google
IdP, plus a parallel Grimmory OIDC client.

## What this manages

- Four `authentik_group` buckets (`users`, `admins`, `grownups`, `kids`).
- `authentik_user` entries from a SOPS-encrypted YAML roster, with
  group memberships derived from per-bucket username lists.
- `authentik_source_oauth` Google source with `user_matching_mode =
  "email_link"`.
- `authentik_provider_oauth2` + `authentik_application` for Grimmory
  (public PKCE client). The client ID is exposed as the
  `grimmory_client_id` output and is **not** wired into Grimmory's
  runtime yet — the app keeps using the Zitadel client until a separate
  apps-repo PR cuts it over.

No `groups` claim is emitted on the Grimmory id_token in this revision;
adding the property mapping is a follow-up spec.

## One-time bootstrap

1. Log into the Authentik admin UI at
   `https://login.cloud.blacksd.tech/if/admin/` from a permitted source
   IP (admin route gated by the existing `authentik-admin-ip-filter`
   SecurityPolicy).
2. Create an Internal Service Account user named `terraform`, add it
   to the built-in `authentik Admins` group, then create an API token
   for it under Tokens & App passwords.
3. Save the token to
   `configs/blacksd/authentik/authentik-token.sops.yaml` as
   `token: <value>`, then `sops --encrypt --in-place
   authentik-token.sops.yaml`.
4. Copy `configs/blacksd/zitadel/users.sops.yaml` and
   `configs/blacksd/zitadel/google-oauth.sops.yaml` to
   `configs/blacksd/authentik/`. The repo-root `.sops.yaml` rule
   (`path_regex: \.sops(?:\.(?:yaml|json))?$`) matches the new paths
   automatically.
5. In the Google Cloud Console, add
   `https://login.cloud.blacksd.tech/source/oauth/callback/google/`
   to the OAuth client's authorized redirect URIs (alongside the
   existing Zitadel callback).

## Day-to-day workflow

```bash
devbox shell
cd configs/blacksd/authentik
terragrunt init    # first run only
terragrunt plan
terragrunt apply
```

## Drifting `users.sops.yaml`

The Zitadel and Authentik config dirs each carry their own copy of
`users.sops.yaml`. Until one of the two IdPs is retired, edits to
either file must be propagated to the other by hand. This is explicit,
time-boxed tech debt.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
