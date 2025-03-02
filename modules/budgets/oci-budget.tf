locals {
  freeform_tags = {
    budget = {
      "Terraform.Component" = "Budget"
    }
  }
}

resource "oci_budget_budget" "zero_spend" {
  amount         = 1
  compartment_id = var.tenancy_ocid
  display_name   = "404-no-budget-found"
  description    = "How much money am I willing to spend on this project."
  target_type    = "COMPARTMENT"
  targets = [
    var.tenancy_ocid
  ]
  processing_period_type = "MONTH"
  reset_period           = "MONTHLY"

  # defined_tags  = { "Operations.CostCenter" = "42" }
  # freeform_tags          = local.freeform_tags.budget
}

resource "oci_budget_alert_rule" "scream_bloody_gore" {
  budget_id      = oci_budget_budget.zero_spend.id
  threshold      = "0.50"
  threshold_type = "ABSOLUTE"
  type           = "FORECAST"
  description    = "Alert at 50% spend"
  display_name   = "wait-this-should-not-cost-money"
  message        = "Please check your config. This is not supposed to cost money."
  recipients     = var.notification_email

  # defined_tags  = { "Operations.CostCenter" = "42" }
  # freeform_tags = local.freeform_tags.budget
}
