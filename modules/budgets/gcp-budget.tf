data "google_project" "this" {}

locals {
  gcp_budget_service_list = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com"
  ])
}

# Resources
resource "google_billing_budget" "zero_cost" {
  provider = google.billing

  billing_account = data.google_billing_account.this.id
  display_name    = "Zero-cost Budget"

  budget_filter {
    calendar_period = "MONTH"
    projects        = ["projects/${data.google_project.this.number}"]
  }

  amount {
    specified_amount {
      currency_code = "EUR"
      # units         = "0"
      nanos = "0"
    }
  }

  threshold_rules {
    threshold_percent = 1.0
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email.id,
    ]
    disable_default_iam_recipients = false
  }

  depends_on = [
    google_project_service.budget_services
  ]
}

resource "google_project_service" "budget_services" {
  for_each = local.gcp_budget_service_list

  project = data.google_project.this.id
  service = each.key
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Spengin Alert - Mail "
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}
