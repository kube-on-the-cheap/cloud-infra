resource "grafana_cloud_access_policy" "vantage" {
  region       = var.grafana_cloud_region
  name         = "vantage"
  display_name = "Vantage Policy"

  scopes = ["billing-metrics:read", "orgs:read"]

  realm {
    type = "org"
    # identifier = data.grafana_cloud_organization.current.id
    identifier = grafana_cloud_stack.this.org_id
  }

  conditions {
    allowed_subnets = []
  }
}

resource "grafana_cloud_access_policy_token" "vantage" {
  region           = var.grafana_cloud_region
  access_policy_id = grafana_cloud_access_policy.vantage.policy_id
  name             = "vantage-token"
  display_name     = "Vantage Token"
}

output "vantage-token" {
  value       = grafana_cloud_access_policy_token.vantage.token
  description = "The Vantage API token to read metrics"
  sensitive   = true
}

# also add usage alerts
# https://grafana.com/docs/grafana-cloud/cost-management-and-billing/set-up-usage-alerts/
