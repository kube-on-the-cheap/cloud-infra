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
