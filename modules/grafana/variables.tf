variable "gc_stack_slug" {
  type        = string
  description = "The Grafana Cloud org slug"
}

# NOTE: available at https://grafana.com/api/stack-regions
variable "gc_region" {
  description = "The region to run the Grafana Cloud stack in"
  default     = "prod-eu-west-2" # AWS Germany
}
