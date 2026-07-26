# Move Authentik & Zitadel Terraform to the apps repo — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move Authentik and Zitadel Terraform modules and Terragrunt configs from `cloud-infra` to `apps`, preserving GCS state prefixes so no resources are recreated.

**Architecture:** Two repos change: `apps` gains a `configs/<app>/<cluster>/` tree containing the reusable module (`configs/<app>/module/`) and per-cluster Terragrunt configs (`configs/<app>/<cluster>/`); `cloud-infra` deletes the corresponding paths. Terragrunt `remote_state` is hardcoded in each per-cluster config with the legacy GCS prefix so `terragrunt plan` returns zero diff after the move.

**Tech Stack:** Terraform 1.10.2, Terragrunt 0.71.2, GCS backend (bucket `kube-on-the-cheap-3st1qzzy`), SOPS (age + PGP), devbox.

**Spec:** `cloud-infra/docs/superpowers/specs/2026-07-26-move-idp-tf-to-apps-repo-design.md`

**Repo paths in this plan:**
- `CI` = `/Users/marco/Repositories/cloud-infra`
- `APPS` = `/Users/marco/Repositories/apps`

---

## Ordering & branching

All `apps` work lands in a single branch, and all `cloud-infra` work lands in a single branch. Merge `apps` first (adds the new tree), then merge `cloud-infra` (deletes the old tree). Do NOT delete anything in `cloud-infra` until `terragrunt plan` in `apps` is clean.

---

## Task 1: Create branches and empty skeleton in `apps`

**Files:**
- Create: `APPS/configs/` (empty dir marker via `.gitkeep`, deleted in Task 3)

- [ ] **Step 1: Create work branch in `apps`**

```bash
cd /Users/marco/Repositories/apps
git checkout main && git pull --ff-only
git checkout -b move-idp-tf-from-cloud-infra
```

- [ ] **Step 2: Create work branch in `cloud-infra`**

```bash
cd /Users/marco/Repositories/cloud-infra
git checkout main && git pull --ff-only
git checkout -b move-idp-tf-to-apps
```

- [ ] **Step 3: Confirm both branches**

Run: `git -C /Users/marco/Repositories/apps branch --show-current && git -C /Users/marco/Repositories/cloud-infra branch --show-current`
Expected output:
```
move-idp-tf-from-cloud-infra
move-idp-tf-to-apps
```

---

## Task 2: Write `apps/configs/general.include.hcl`

**Files:**
- Create: `APPS/configs/general.include.hcl`

- [ ] **Step 1: Create `configs/` and write the include**

```bash
mkdir -p /Users/marco/Repositories/apps/configs
```

Then create `APPS/configs/general.include.hcl` with EXACTLY this content:

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

- [ ] **Step 2: Verify file**

Run: `cat /Users/marco/Repositories/apps/configs/general.include.hcl | head -5`
Expected: prints the `locals { project_details = {` block.

- [ ] **Step 3: Commit**

```bash
cd /Users/marco/Repositories/apps
git add configs/general.include.hcl
git commit -m "feat(configs): add general.include.hcl for Terragrunt-managed post-deploy IdP configs"
```

---

## Task 3: Update `apps/.sops.yaml` for `configs/**`

**Files:**
- Modify: `APPS/.sops.yaml`

**Context:** existing rules encrypt `overlays/<cluster>/*.sops.yaml` to per-cluster age keys (consumed inside the cluster by `kubernetes-sops`). The moved IdP secrets are only decrypted locally by Terragrunt and must go to the operator's keys only, mirroring `cloud-infra/.sops.yaml`.

- [ ] **Step 1: Read current file to confirm anchor names**

Run: `head -12 /Users/marco/Repositories/apps/.sops.yaml`
Expected: sees `&Marco_pgp B31C0D06E2C1EB5A` and `&Marco_age_backup age1k9pgstv92fnq4mpupu2msd9j7zvv96l07ueqfckrv3nwq94t7vzq7typqx`. If either anchor name differs, use the actual names in Step 2.

- [ ] **Step 2: Append two rules to `creation_rules`**

Insert these two entries at the END of the `creation_rules:` list (before the `stores:` block if present) in `APPS/.sops.yaml`:

```yaml
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

- [ ] **Step 3: Validate YAML**

Run: `yq '.creation_rules | length' /Users/marco/Repositories/apps/.sops.yaml`
Expected: `4` (was 2, added 2).

- [ ] **Step 4: Commit**

```bash
cd /Users/marco/Repositories/apps
git add .sops.yaml
git commit -m "chore(sops): allow encrypting configs/**/*.sops.{yaml,json} with operator keys"
```

---

## Task 4: Add Terraform tools to `apps/devbox.json`

**Files:**
- Modify: `APPS/devbox.json`

- [ ] **Step 1: Add four packages**

In `APPS/devbox.json`, add these strings to the `packages` array (order doesn't matter, but keep the array sorted alphabetically for consistency with cloud-infra style):

```json
    "terraform@1.10.2",
    "terraform-docs@0.19.0",
    "terraform-ls@0.36.4",
    "terragrunt@0.71.2",
```

- [ ] **Step 2: Refresh devbox lock**

```bash
cd /Users/marco/Repositories/apps
devbox install
```

Expected: devbox resolves the four new packages, updates `devbox.lock`. No errors.

- [ ] **Step 3: Verify the tools are on PATH inside devbox**

```bash
cd /Users/marco/Repositories/apps
devbox shell -- terraform version
devbox shell -- terragrunt --version
```

Expected: prints `Terraform v1.10.2` and `terragrunt version v0.71.2` (or exact patch). If `devbox shell --` is not supported by the installed devbox version, activate the shell interactively (`devbox shell`) and run the two commands manually.

- [ ] **Step 4: Commit**

```bash
cd /Users/marco/Repositories/apps
git add devbox.json devbox.lock
git commit -m "chore(devbox): add terraform, terragrunt, terraform-docs, terraform-ls"
```

---

## Task 5: Add `.gitignore` entries in `apps` for Terraform artifacts

**Files:**
- Modify: `APPS/.gitignore`

- [ ] **Step 1: Append Terraform ignores**

Append to `APPS/.gitignore`:

```
# Terragrunt
**/.terragrunt-cache
# Terraform
**/.terraform
**/*.tfstate
**/*.tfstate.backup
**/*.tfstate.*.backup
**/*.tfplan
**/*.tfvars
**/*.tfvars.json
**/*.auto.tfvars
# Terraform locks are useful only in root modules
configs/**/.terraform.lock.hcl
```

- [ ] **Step 2: Sanity check**

Run: `grep -c terragrunt-cache /Users/marco/Repositories/apps/.gitignore`
Expected: `1`

- [ ] **Step 3: Commit**

```bash
cd /Users/marco/Repositories/apps
git add .gitignore
git commit -m "chore(gitignore): ignore terraform & terragrunt local artifacts"
```

---

## Task 6: Copy Authentik Terraform module into `apps/configs/authentik/module/`

**Files:**
- Create: `APPS/configs/authentik/module/*` (copies of `CI/modules/authentik/*.tf` + `README.md`)

**Context:** we `cp` (not `git mv`) because the files cross repository boundaries. `git rm` in `cloud-infra` happens in Task 12.

- [ ] **Step 1: Create target dir and copy source files**

```bash
mkdir -p /Users/marco/Repositories/apps/configs/authentik/module
cp /Users/marco/Repositories/cloud-infra/modules/authentik/*.tf \
   /Users/marco/Repositories/cloud-infra/modules/authentik/README.md \
   /Users/marco/Repositories/apps/configs/authentik/module/
```

- [ ] **Step 2: Verify file set matches source**

```bash
diff <(ls /Users/marco/Repositories/cloud-infra/modules/authentik | grep -Ev '^\.terraform') \
     <(ls /Users/marco/Repositories/apps/configs/authentik/module)
```

Expected: no output (identical file listings, ignoring `.terraform*`).

- [ ] **Step 3: Commit**

```bash
cd /Users/marco/Repositories/apps
git add configs/authentik/module
git commit -m "feat(configs/authentik): import Terraform module from cloud-infra"
```

---

## Task 7: Copy Zitadel Terraform module into `apps/configs/zitadel/module/`

**Files:**
- Create: `APPS/configs/zitadel/module/*` (copies of `CI/modules/zitadel/*.tf` + `README.md`)

- [ ] **Step 1: Create target dir and copy source files**

```bash
mkdir -p /Users/marco/Repositories/apps/configs/zitadel/module
cp /Users/marco/Repositories/cloud-infra/modules/zitadel/*.tf \
   /Users/marco/Repositories/cloud-infra/modules/zitadel/README.md \
   /Users/marco/Repositories/apps/configs/zitadel/module/
```

- [ ] **Step 2: Verify file set matches source**

```bash
diff <(ls /Users/marco/Repositories/cloud-infra/modules/zitadel | grep -Ev '^\.terraform') \
     <(ls /Users/marco/Repositories/apps/configs/zitadel/module)
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
cd /Users/marco/Repositories/apps
git add configs/zitadel/module
git commit -m "feat(configs/zitadel): import Terraform module from cloud-infra"
```

---

## Task 8: Copy Authentik `freeloader` Terragrunt config and rewrite `terragrunt.hcl`

**Files:**
- Create: `APPS/configs/authentik/freeloader/authentik-token.sops.yaml`
- Create: `APPS/configs/authentik/freeloader/google-oauth.sops.yaml`
- Create: `APPS/configs/authentik/freeloader/users.sops.yaml`
- Create: `APPS/configs/authentik/freeloader/terragrunt.hcl` (rewritten, not copied)

- [ ] **Step 1: Copy SOPS-encrypted inputs verbatim**

```bash
mkdir -p /Users/marco/Repositories/apps/configs/authentik/freeloader
cp /Users/marco/Repositories/cloud-infra/configs/blacksd/authentik/authentik-token.sops.yaml \
   /Users/marco/Repositories/cloud-infra/configs/blacksd/authentik/google-oauth.sops.yaml \
   /Users/marco/Repositories/cloud-infra/configs/blacksd/authentik/users.sops.yaml \
   /Users/marco/Repositories/apps/configs/authentik/freeloader/
```

- [ ] **Step 2: Verify SOPS files still decrypt at the new path**

```bash
cd /Users/marco/Repositories/apps/configs/authentik/freeloader
sops -d authentik-token.sops.yaml | head -1
```

Expected: prints `token: ...` (decrypts successfully). The `.sops.yaml` rule from Task 3 governs future writes; existing ciphertext decrypts regardless of path because it embeds the recipients.

- [ ] **Step 3: Write the new `terragrunt.hcl`**

Create `APPS/configs/authentik/freeloader/terragrunt.hcl` with EXACTLY this content:

```hcl
terraform {
  source = "../module"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = "kube-on-the-cheap-3st1qzzy"
    prefix   = "blacksd/authentik/terraform.tfstate"
    project  = "kube-on-the-cheap"
    location = "europe-west3"
  }
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
  family               = try(local.users_data.groups.family, [])
  admins               = try(local.users_data.groups.admins, [])
  grownups             = try(local.users_data.groups.grownups, [])
  kids                 = try(local.users_data.groups.kids, [])
}
```

**Diff from the old `cloud-infra/configs/blacksd/authentik/terragrunt.hcl`:**
- `source = "../../..//modules/authentik"` → `source = "../module"`
- Added explicit `remote_state` block with the legacy GCS prefix (replaces the one inherited from the old `general.include.hcl`).

- [ ] **Step 4: Format check**

```bash
cd /Users/marco/Repositories/apps
devbox run -- terragrunt hclfmt --check configs/authentik/freeloader/terragrunt.hcl
```

Expected: exits 0 (already formatted).

- [ ] **Step 5: Commit**

```bash
cd /Users/marco/Repositories/apps
git add configs/authentik/freeloader
git commit -m "feat(configs/authentik/freeloader): import Terragrunt config from cloud-infra"
```

---

## Task 9: Copy Zitadel `freeloader` Terragrunt config and rewrite `terragrunt.hcl`

**Files:**
- Create: `APPS/configs/zitadel/freeloader/google-oauth.sops.yaml`
- Create: `APPS/configs/zitadel/freeloader/users.sops.yaml`
- Create: `APPS/configs/zitadel/freeloader/zitadel-key.sops.json`
- Create: `APPS/configs/zitadel/freeloader/terragrunt.hcl`

- [ ] **Step 1: Copy SOPS-encrypted inputs verbatim**

```bash
mkdir -p /Users/marco/Repositories/apps/configs/zitadel/freeloader
cp /Users/marco/Repositories/cloud-infra/configs/blacksd/zitadel/google-oauth.sops.yaml \
   /Users/marco/Repositories/cloud-infra/configs/blacksd/zitadel/users.sops.yaml \
   /Users/marco/Repositories/cloud-infra/configs/blacksd/zitadel/zitadel-key.sops.json \
   /Users/marco/Repositories/apps/configs/zitadel/freeloader/
```

- [ ] **Step 2: Verify SOPS files decrypt at the new path**

```bash
cd /Users/marco/Repositories/apps/configs/zitadel/freeloader
sops -d google-oauth.sops.yaml | head -1
sops -d zitadel-key.sops.json | jq -r '.type' | head -1
```

Expected: prints `client_id: ...` for the YAML and `serviceaccount` (or similar) for the JSON.

- [ ] **Step 3: Write the new `terragrunt.hcl`**

Create `APPS/configs/zitadel/freeloader/terragrunt.hcl` with EXACTLY this content:

```hcl
terraform {
  source = "../module"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = "kube-on-the-cheap-3st1qzzy"
    prefix   = "blacksd/zitadel/terraform.tfstate"
    project  = "kube-on-the-cheap"
    location = "europe-west3"
  }
}

locals {
  google_oauth = yamldecode(sops_decrypt_file("./google-oauth.sops.yaml"))
  users_data   = yamldecode(sops_decrypt_file("./users.sops.yaml"))
}

inputs = {
  zitadel_domain           = "auth.cloud.blacksd.tech"
  zitadel_jwt_profile_json = sops_decrypt_file("./zitadel-key.sops.json")
  google_client_id         = local.google_oauth.client_id
  google_client_secret     = local.google_oauth.client_secret
  users                    = local.users_data.users
  users_group              = try(local.users_data.groups.users, [])
  admins                   = try(local.users_data.groups.admins, [])
  grownups                 = try(local.users_data.groups.grownups, [])
  kids                     = try(local.users_data.groups.kids, [])
}
```

**Diff from `cloud-infra/configs/blacksd/zitadel/terragrunt.hcl`:**
- `source = "../../..//modules/zitadel"` → `source = "../module"`
- Added explicit `remote_state` block with the legacy GCS prefix.

- [ ] **Step 4: Format check**

```bash
cd /Users/marco/Repositories/apps
devbox run -- terragrunt hclfmt --check configs/zitadel/freeloader/terragrunt.hcl
```

Expected: exits 0.

- [ ] **Step 5: Commit**

```bash
cd /Users/marco/Repositories/apps
git add configs/zitadel/freeloader
git commit -m "feat(configs/zitadel/freeloader): import Terragrunt config from cloud-infra"
```

---

## Task 10: Verify Authentik plan is clean (state prefix works)

**Files:** no changes, verification only.

**Context:** this is the go/no-go gate. If `terragrunt plan` shows any diff, STOP and investigate before proceeding. Possible causes:
1. `remote_state.prefix` typo → Terraform sees empty state, plans full create.
2. Provider version drift → check `.terraform.lock.hcl` against the source.
3. Input mismatch → diff the new `terragrunt.hcl` inputs vs the old one.

- [ ] **Step 1: Ensure GCP application-default credentials are present**

```bash
gcloud auth application-default print-access-token >/dev/null 2>&1 && echo OK || echo "run: gcloud auth application-default login"
```

Expected: `OK`. Otherwise run the suggested login command interactively.

- [ ] **Step 2: Terragrunt init**

```bash
cd /Users/marco/Repositories/apps/configs/authentik/freeloader
devbox run -c /Users/marco/Repositories/apps -- terragrunt init
```

Expected: `Terraform has been successfully initialized!` with backend `gcs`, prefix `blacksd/authentik/terraform.tfstate`.

- [ ] **Step 3: Terragrunt plan**

```bash
cd /Users/marco/Repositories/apps/configs/authentik/freeloader
devbox run -c /Users/marco/Repositories/apps -- terragrunt plan
```

Expected (mandatory):
```
No changes. Your infrastructure matches the configuration.
```

If ANY resource is planned for create/update/destroy: **stop**, revert to the old path (`cloud-infra`) for actual operations, and diagnose. Do not proceed to Task 12.

- [ ] **Step 4: Record confirmation**

Note the successful plan in the PR description when opened. No file changes in this task.

---

## Task 11: Verify Zitadel plan is clean

**Files:** no changes, verification only.

- [ ] **Step 1: Terragrunt init**

```bash
cd /Users/marco/Repositories/apps/configs/zitadel/freeloader
devbox run -c /Users/marco/Repositories/apps -- terragrunt init
```

Expected: backend `gcs`, prefix `blacksd/zitadel/terraform.tfstate`, initialized successfully.

- [ ] **Step 2: Terragrunt plan**

```bash
cd /Users/marco/Repositories/apps/configs/zitadel/freeloader
devbox run -c /Users/marco/Repositories/apps -- terragrunt plan
```

Expected:
```
No changes. Your infrastructure matches the configuration.
```

Same stop rule as Task 10 if the plan is not empty.

---

## Task 12: Push `apps` branch and open PR

**Files:** no source changes.

- [ ] **Step 1: Push branch**

```bash
cd /Users/marco/Repositories/apps
git push -u origin move-idp-tf-from-cloud-infra
```

- [ ] **Step 2: Open PR**

```bash
cd /Users/marco/Repositories/apps
gh pr create --title "feat(configs): import Authentik & Zitadel Terraform from cloud-infra" --body "$(cat <<'EOF'
## Summary

- Adds `configs/<app>/<cluster>/` tree for post-deploy IdP Terraform.
- Imports `authentik` and `zitadel` modules and their `freeloader` Terragrunt configs from `cloud-infra` (see companion PR there).
- Adds `terraform`, `terragrunt`, `terraform-docs`, `terraform-ls` to devbox.
- Adds SOPS rules for `configs/**/*.sops.{yaml,json}` (operator keys only).
- Adds `.gitignore` entries for Terraform/Terragrunt artifacts.

State prefixes are frozen to the legacy paths (`blacksd/authentik/terraform.tfstate`, `blacksd/zitadel/terraform.tfstate`) in the same GCS bucket, so `terragrunt plan` returns "No changes" for both.

Spec: cloud-infra `docs/superpowers/specs/2026-07-26-move-idp-tf-to-apps-repo-design.md`.

## Test plan

- [x] `terragrunt plan` in `configs/authentik/freeloader` → No changes
- [x] `terragrunt plan` in `configs/zitadel/freeloader` → No changes
- [x] `sops -d` succeeds on all moved encrypted files
- [x] `devbox run -- terraform version` and `terragrunt --version` return expected versions
- [ ] Companion `cloud-infra` PR merged AFTER this one

## Ordering

Merge this PR FIRST. Only after it lands, merge the companion PR in `cloud-infra` that deletes the old paths.
EOF
)"
```

Expected: `gh` prints the PR URL. Note it for the companion PR.

---

## Task 13: Delete moved paths from `cloud-infra`

**Files:**
- Delete: `CI/modules/authentik/` (entire directory)
- Delete: `CI/modules/zitadel/` (entire directory)
- Delete: `CI/configs/blacksd/authentik/` (entire directory)
- Delete: `CI/configs/blacksd/zitadel/` (entire directory)

- [ ] **Step 1: Confirm the `apps` PR has been merged**

Do not proceed until the `apps` PR from Task 12 is merged to `main`. Otherwise the code is briefly homeless in Git.

- [ ] **Step 2: Remove modules**

```bash
cd /Users/marco/Repositories/cloud-infra
git rm -r modules/authentik modules/zitadel
```

- [ ] **Step 3: Remove per-cluster configs**

```bash
cd /Users/marco/Repositories/cloud-infra
git rm -r configs/blacksd/authentik configs/blacksd/zitadel
```

- [ ] **Step 4: Verify no dangling references**

```bash
cd /Users/marco/Repositories/cloud-infra
rg -n 'modules/authentik|modules/zitadel|blacksd/authentik|blacksd/zitadel' --hidden || echo "no references"
```

Expected: `no references`. If any hit appears, inspect it and remove the reference before committing.

- [ ] **Step 5: Commit**

```bash
cd /Users/marco/Repositories/cloud-infra
git commit -m "chore: remove Authentik & Zitadel Terraform (moved to apps repo)"
```

---

## Task 14: Push `cloud-infra` branch and open PR

**Files:** no source changes.

- [ ] **Step 1: Push branch**

```bash
cd /Users/marco/Repositories/cloud-infra
git push -u origin move-idp-tf-to-apps
```

- [ ] **Step 2: Open PR referencing the merged apps PR**

Replace `<APPS_PR_URL>` with the URL from Task 12.

```bash
cd /Users/marco/Repositories/cloud-infra
gh pr create --title "chore: remove Authentik & Zitadel Terraform (moved to apps repo)" --body "$(cat <<'EOF'
## Summary

- Removes `modules/{authentik,zitadel}` and `configs/blacksd/{authentik,zitadel}`.
- These now live in the apps repo under `configs/<app>/<cluster>/`; see <APPS_PR_URL>.
- No Terragrunt state migration was required — GCS bucket and prefixes are preserved by the new configs.

Spec: `docs/superpowers/specs/2026-07-26-move-idp-tf-to-apps-repo-design.md`.

## Test plan

- [x] Companion apps PR merged: <APPS_PR_URL>
- [x] `terragrunt plan` from the new apps paths returns "No changes"
- [x] `rg 'modules/authentik|modules/zitadel|blacksd/authentik|blacksd/zitadel'` in this repo returns nothing
- [x] Login at `https://login.cloud.blacksd.tech` still works
EOF
)"
```

Expected: `gh` prints the PR URL.

---

## Task 15: Post-merge smoke test

**Files:** none.

- [ ] **Step 1: End-to-end login check**

Open `https://login.cloud.blacksd.tech` in a browser and sign in with the Google IdP. Verify redirect to the Authentik dashboard.

- [ ] **Step 2: Terragrunt sanity check from `main`**

```bash
cd /Users/marco/Repositories/apps
git checkout main && git pull --ff-only
cd configs/authentik/freeloader
devbox run -c /Users/marco/Repositories/apps -- terragrunt plan
```

Expected: `No changes.`

- [ ] **Step 3: Same for Zitadel**

```bash
cd /Users/marco/Repositories/apps/configs/zitadel/freeloader
devbox run -c /Users/marco/Repositories/apps -- terragrunt plan
```

Expected: `No changes.`

---

## Rollback

If any step from Task 10 onward fails and the `apps` code is broken but no PRs are merged yet:

```bash
cd /Users/marco/Repositories/apps && git checkout main && git branch -D move-idp-tf-from-cloud-infra
cd /Users/marco/Repositories/cloud-infra && git checkout main && git branch -D move-idp-tf-to-apps
```

If the `apps` PR is merged but `cloud-infra` deletions haven't happened yet, the system is fine — both trees exist, only the new one is authoritative for Terragrunt. Continue with Task 13 when ready, or revert the `apps` merge if the new tree is unusable.

If the `cloud-infra` deletion PR is merged but the new tree turns out broken, restore from git:

```bash
cd /Users/marco/Repositories/cloud-infra
git checkout <sha-before-deletion> -- modules/authentik modules/zitadel configs/blacksd/authentik configs/blacksd/zitadel
git commit -m "revert: restore Authentik & Zitadel Terraform"
```

No state migration is needed either way because the GCS prefix never moved.
