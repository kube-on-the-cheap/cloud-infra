---
name: move-idp-tf-to-apps-repo
description: Relocate the Authentik and Zitadel Terraform modules and Terragrunt configs from cloud-infra to the apps repo, keeping this repo scoped to infrastructure.
status: draft
scope: cross-repo (cloud-infra, apps)
---

# Move Authentik & Zitadel Terraform to the apps repo

## Motivation

`cloud-infra` should describe cloud infrastructure. The Authentik and Zitadel
Terraform code under `cloud-infra/modules/{authentik,zitadel}` and
`cloud-infra/configs/blacksd/{authentik,zitadel}` is app-level configuration:
it talks to the running IdP over HTTPS to declare users, groups, IdPs, and
OIDC clients. It runs *after* the app is deployed by Flux, using an API token
minted from inside the cluster.

Co-locating this code with the rest of each app in the `apps` repo makes the
ownership boundary clearer: `cloud-infra` provisions the platform, `apps`
declares what lives on it, including post-deploy IdP state.

## Target layout (`apps` repo)

```
apps/
├── apps/                          # unchanged  Kustomize/Flux manifests
│   ├── authentik/{base,overlays/freeloader}/
│   └── zitadel/{base,overlays/freeloader}/
├── clusters/                      # unchanged  Flux entrypoints
├── configs/                       # NEW  Terraform/Terragrunt post-deploy config
│   ├── general.include.hcl
│   ├── authentik/
│   │   ├── module/                # ex cloud-infra/modules/authentik/
│   │   │   ├── main.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   │   ├── flows.tf
│   │   │   ├── google_idp.tf
│   │   │   ├── grimmory.tf
│   │   │   ├── groups.tf
│   │   │   ├── login_stage.tf
│   │   │   ├── system_settings.tf
│   │   │   ├── users.tf
│   │   │   ├── akadmin.tf
│   │   │   └── README.md
│   │   └── freeloader/            # ex cloud-infra/configs/blacksd/authentik/
│   │       ├── terragrunt.hcl
│   │       ├── authentik-token.sops.yaml
│   │       ├── google-oauth.sops.yaml
│   │       └── users.sops.yaml
│   └── zitadel/
│       ├── module/                # ex cloud-infra/modules/zitadel/
│       │   ├── main.tf
│       │   ├── providers.tf
│       │   ├── variables.tf
│       │   ├── org.tf
│       │   ├── project.tf
│       │   ├── project_roles.tf
│       │   ├── user_grants.tf
│       │   ├── users.tf
│       │   ├── groups_action.tf
│       │   ├── google_idp.tf
│       │   ├── grimmory.tf
│       │   ├── login_policy.tf
│       │   └── README.md
│       └── freeloader/            # ex cloud-infra/configs/blacksd/zitadel/
│           ├── terragrunt.hcl
│           ├── google-oauth.sops.yaml
│           ├── users.sops.yaml
│           └── zitadel-key.sops.json
├── devbox.json                    # + terraform, terragrunt, terraform-docs
├── .sops.yaml                     # + rules for configs/**/*.sops.{yaml,json}
└── Taskfile.yaml                  # NEW (optional)  wraps terragrunt run
```

### Layout rationale

- `configs/<app>/<cluster>/` mirrors `apps/<app>/overlays/<cluster>/` so the
  mental model is consistent: an app is a top-level name, a cluster is the
  next level down.
- Flux only follows `clusters/` → `apps/apps/`. `configs/` is invisible to
  it, so there is no risk of it trying to apply Terragrunt files.
- Each app owns its Terraform module in `configs/<app>/module/`. The module
  is 1:1 with the app; a shared `_modules/` layer would be premature.
- Not every app will have multiple deployments. When one does (e.g. adding
  `understairs`), it slots in as `configs/<app>/understairs/`.

## State backend

The current Terraform state lives in the GCS bucket
`kube-on-the-cheap-3st1qzzy` under prefixes derived from
`path_relative_to_include()`, which today resolves to:

- `blacksd/authentik/terraform.tfstate`
- `blacksd/zitadel/terraform.tfstate`

Under the new path `apps/configs/<app>/<cluster>/`, that helper would resolve
to `<app>/<cluster>/terraform.tfstate`  a different key, which Terraform
would treat as an empty state and try to re-create every resource.

To preserve state and avoid any migration, each new
`configs/<app>/<cluster>/terragrunt.hcl` overrides `prefix` explicitly:

```hcl
remote_state {
  backend = "gcs"
  config = {
    bucket = "kube-on-the-cheap-3st1qzzy"
    prefix = "blacksd/authentik/terraform.tfstate"  # frozen legacy key
    project  = "kube-on-the-cheap"
    location = "europe-west3"
  }
}
```

An alternative is to keep `remote_state` in `general.include.hcl` and pass
the prefix in via a `locals`/`inputs` override per-cluster; the design uses
the explicit form above for readability. Either way, the bucket, project,
and location stay identical to `cloud-infra/configs/general.include.hcl`.

The GCP service account used by Terragrunt (currently sourced from
`gcloud auth application-default login` per-developer) is unchanged  it
already has write access to that bucket.

## `configs/general.include.hcl`

A slim analogue of `cloud-infra/configs/general.include.hcl`, containing
only what the IdP configs actually consume:

```hcl
locals {
  project_details = {
    name       = "Kube, on the cheap"
    short_form = "kube-on-the-cheap"
  }
  gcp = {
    region     = "europe-west3"
    project_id = local.project_details.short_form
  }
  state_bucket = "kube-on-the-cheap-3st1qzzy"
  domain_name  = "blacksd.tech"
}

inputs = {
  domain_name       = local.domain_name
  cloud_domain_name = "cloud.${local.domain_name}"
}

terraform_version_constraint  = "~> 1.10.0"
terragrunt_version_constraint = "~> 0.71.0"
```

No `remote_state` block here (each config sets its own frozen prefix). No
OCI/OKE/DNS/bastion inputs.

## SOPS

`apps/.sops.yaml` today only covers `overlays/<cluster>/*.sops.yaml` and
encrypts to the cluster's age key plus the personal backup keys (so that
`kubernetes-sops` inside the cluster can decrypt them at Flux
reconciliation time).

The moved IdP secrets are *not* consumed inside the cluster; they are only
decrypted locally by Terragrunt. They must be encrypted to the operator's
keys only  same as the current `cloud-infra` rule.

Add two new creation rules to `apps/.sops.yaml`:

```yaml
creation_rules:
  # ...existing overlays rules...
  - path_regex: ^configs/.*\.sops\.yaml$
    key_groups:
      - pgp:
          - *Marco_pgp
        age:
          - *Marco_age_backup
  - path_regex: ^configs/.*\.sops\.json$
    key_groups:
      - pgp:
          - *Marco_pgp
        age:
          - *Marco_age_backup
```

Because the files being moved are already encrypted to exactly those two
keys (per `cloud-infra/.sops.yaml`), no re-encryption is needed. `git mv`
preserves ciphertext; `sops` decrypts them unchanged.

## devbox

Add to `apps/devbox.json` `packages`:

- `terraform@1.10.2`
- `terragrunt@0.71.2`
- `terraform-docs@0.19.0`
- `terraform-ls@0.36.4`

Versions match `cloud-infra/devbox.json` to avoid drift. `sops` is already
present in `apps/devbox.json`.

## Taskfile (optional)

`cloud-infra` has a top-level `Taskfile.yaml` that includes per-config
taskfiles. `apps` has none today. The design does *not* add a Taskfile in
this move  operators can `cd configs/<app>/<cluster> && terragrunt apply`
directly, matching how `oci-dns` and `budgets` are used in `cloud-infra`
where no per-config Taskfile exists.

If usage patterns later justify one, a `Taskfile.yaml` can be added
without changing the layout.

## Cutover plan (high-level  detailed steps go in the impl plan)

1. In `apps` repo, create the `configs/` skeleton, `general.include.hcl`,
   and updated `.sops.yaml` and `devbox.json`. Do not move files yet.
2. `git mv` (or `cp -R` + `git rm` if crossing repos requires it):
   - `cloud-infra/modules/authentik/` → `apps/configs/authentik/module/`
   - `cloud-infra/modules/zitadel/`   → `apps/configs/zitadel/module/`
   - `cloud-infra/configs/blacksd/authentik/` → `apps/configs/authentik/freeloader/`
   - `cloud-infra/configs/blacksd/zitadel/`   → `apps/configs/zitadel/freeloader/`
3. In each moved `terragrunt.hcl`:
   - Change `source = "../../..//modules/<app>"` to `source = "../module"`.
   - Add the explicit `remote_state` block with the legacy prefix.
   - Change `include "general"` to point at
     `find_in_parent_folders("general.include.hcl")` (still works; the new
     `general.include.hcl` sits at `apps/configs/`).
4. `terragrunt init && terragrunt plan` in each cluster dir. Expect a
   clean plan (no diff) since the state key is preserved and inputs are
   unchanged.
5. In `cloud-infra`:
   - `git rm -r modules/{authentik,zitadel}` and
     `git rm -r configs/blacksd/{authentik,zitadel}`.
   - Remove any references from `cloud-infra/Taskfile.yaml` (currently
     none for authentik/zitadel  double-check before removing).
   - Update `cloud-infra/README.md` / `configs/README.md` if they mention
     these modules (they currently do not).
6. Commit both repos. The `apps` commit lands first (moves + config), the
   `cloud-infra` commit lands second (deletions).

## What stays in `cloud-infra`

- `modules/oci-*`, `modules/oci-dns`, `modules/oci-oke`, `modules/platform-bootstrap`,
  `modules/tailscale`, `modules/object-storage`, `modules/email`, `modules/grafana`,
  `modules/budgets`  all cloud/platform infrastructure.
- `configs/blacksd/` minus the two removed subdirs.
- `configs/general.include.hcl` unchanged  still consumed by the remaining
  configs.

## Non-goals

- No change to what the Terraform code *does*. Zero resource churn is the
  success criterion.
- No secrets rotation. Same ciphertext, same keys.
- No change to how Flux deploys the IdPs. Kustomize manifests under
  `apps/apps/{authentik,zitadel}/` are untouched.
- No new CI. If pre-commit hooks in `apps` currently ignore Terraform,
  they can stay that way; adding `terraform fmt` / `terraform-docs` hooks
  is out of scope.

## Risks

- **State prefix mistake**: if the frozen prefix in the new `terragrunt.hcl`
  is off by a character, Terraform will plan a full re-creation. Mitigation:
  the plan step in the cutover MUST show zero diff before proceeding.
- **Two toolchains in `apps`**: contributors touching only Kustomize now
  see Terraform files in the tree. Mitigation: `configs/` is a clearly
  named sibling directory; devbox picks up the extra tools transparently.
- **Cross-repo commit ordering**: if `cloud-infra` deletions land first,
  the code is briefly homeless in Git. Mitigation: land `apps` first.

## Success criteria

- `apps/configs/<app>/<cluster>/terragrunt.hcl plan` shows no changes for
  both Authentik and Zitadel on `freeloader`.
- `cloud-infra` has no `modules/{authentik,zitadel}` or
  `configs/blacksd/{authentik,zitadel}` directories.
- `apps` devbox shell exposes `terraform`, `terragrunt`, and `sops` in one
  environment.
- Login at `https://login.cloud.blacksd.tech` continues to work end-to-end
  after the cutover (proves the IdP state was not perturbed).
