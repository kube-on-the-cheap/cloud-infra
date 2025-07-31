resource "grafana_cloud_access_policy" "otel_home_collector" {
  region       = var.grafana_cloud_region
  name         = "otel-home-collector"
  display_name = "OpenTelemetry Home Collector Policy"

  scopes = [
    "metrics:read",
    "metrics:write",
    "metrics:import",
    "logs:write",
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

resource "time_rotating" "otel_home_collector_three_years" {
  rotation_years = 3
}

resource "grafana_cloud_access_policy_token" "otel_home_collector" {
  region           = var.grafana_cloud_region
  access_policy_id = grafana_cloud_access_policy.otel_home_collector.policy_id
  name             = "otel-home-collector-token"
  display_name     = "OpenTelemetry Home Collector Token"
  expires_at       = time_rotating.otel_home_collector_three_years.rotation_rfc3339
}

output "otel_home_collector_token" {
  value       = grafana_cloud_access_policy_token.otel_home_collector.token
  description = "The otel_home_collector API token to push metrics"
  sensitive   = true
}
