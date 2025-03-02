terraform {
  source = "../../..//modules/budgets"
}

include "general" {
  path = find_in_parent_folders("general.include.hcl")
}

inputs = {
  gcp_billing_account_name = "cheapskate"
  notification_email       = "marco.bulgarini@gmail.com"
}
