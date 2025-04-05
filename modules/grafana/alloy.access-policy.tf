# data "grafana_cloud_organization" "current" {
#   slug = var.gc_stack_slug
# }

resource "grafana_cloud_access_policy" "alloy" {
  region       = var.grafana_cloud_region
  name         = "alloy"
  display_name = "Alloy Policy"

  scopes = ["metrics:write",
    "logs:write",
    "traces:write",
    "profiles:write",
    "metrics:read",
    "fleet-management:read",
  ]

  realm {
    type = "org"
    # identifier = data.grafana_cloud_organization.current.id
    identifier = grafana_cloud_stack.this.org_id
  }

  conditions {
    allowed_subnets = []
  }
}

resource "time_rotating" "three_years" {
  rotation_years = 3
}

resource "grafana_cloud_access_policy_token" "alloy" {
  region           = var.grafana_cloud_region
  access_policy_id = grafana_cloud_access_policy.alloy.policy_id
  name             = "alloy-token"
  display_name     = "Alloy Token"
  expires_at       = time_rotating.three_years.rotation_rfc3339
}
