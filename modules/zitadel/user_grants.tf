# Users in var.users_group get the `users` role.
resource "zitadel_user_grant" "users" {
  for_each = toset(nonsensitive(var.users_group))

  org_id     = local.org_id
  project_id = zitadel_project.homelab.id
  user_id    = zitadel_human_user.users[each.value].id
  role_keys  = [zitadel_project_role.users.role_key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.users), each.value)
      error_message = "user '${each.value}' is not present in var.users. Add them to the users map or remove them from var.users_group."
    }
  }
}

# Users in var.admins additionally get the `admins` role.
resource "zitadel_user_grant" "admins" {
  for_each = toset(nonsensitive(var.admins))

  org_id     = local.org_id
  project_id = zitadel_project.homelab.id
  user_id    = zitadel_human_user.users[each.value].id
  role_keys  = [zitadel_project_role.admins.role_key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.users), each.value)
      error_message = "admin '${each.value}' is not present in var.users. Add them to the users map or remove them from var.admins."
    }
  }
}

# Users in var.grownups additionally get the `grownups` role.
resource "zitadel_user_grant" "grownups" {
  for_each = toset(nonsensitive(var.grownups))

  org_id     = local.org_id
  project_id = zitadel_project.homelab.id
  user_id    = zitadel_human_user.users[each.value].id
  role_keys  = [zitadel_project_role.grownups.role_key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.users), each.value)
      error_message = "grownup '${each.value}' is not present in var.users. Add them to the users map or remove them from var.grownups."
    }
  }
}

# Users in var.kids additionally get the `kids` role.
resource "zitadel_user_grant" "kids" {
  for_each = toset(nonsensitive(var.kids))

  org_id     = local.org_id
  project_id = zitadel_project.homelab.id
  user_id    = zitadel_human_user.users[each.value].id
  role_keys  = [zitadel_project_role.kids.role_key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.users), each.value)
      error_message = "kid '${each.value}' is not present in var.users. Add them to the users map or remove them from var.kids."
    }
  }
}
