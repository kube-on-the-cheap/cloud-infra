variable "grafana_cloud_slug" {
  description = "Grafana Cloud slug used to create the corresponding Stack."
  type        = string
  default     = null
}

# NOTE: available at https://grafana.com/api/stack-regions
variable "grafana_cloud_region" {
  description = "The region to run the Grafana Cloud stack in"
  default     = "prod-eu-west-2" # AWS Germany
}
