resource "grafana_cloud_access_policy" "alloy_onprem" {
  region       = var.grafana_cloud_region
  name         = "alloy-onprem"
  display_name = "Alloy On-Prem Policy"

  scopes = ["metrics:write",
    "logs:write",
    "traces:write",
    "profiles:write",
    "metrics:read",
    "fleet-management:read",
  ]

  realm {
    type       = "org"
    identifier = grafana_cloud_stack.this.org_id
  }

  conditions {
    allowed_subnets = []
  }
}

resource "grafana_cloud_access_policy_token" "alloy_onprem" {
  region           = var.grafana_cloud_region
  access_policy_id = grafana_cloud_access_policy.alloy_onprem.policy_id
  name             = "alloy-onprem-token"
  display_name     = "Alloy On-Prem Token"
  expires_at       = time_rotating.three_years.rotation_rfc3339
}

output "alloy_onprem_token" {
  value       = grafana_cloud_access_policy_token.alloy_onprem.token
  description = "The Alloy on-prem API token for the understairs cluster"
  sensitive   = true
}
