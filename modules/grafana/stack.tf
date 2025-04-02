variable "cloud_domain_host_grafana" {
  type        = string
  description = "The custom URL to set. Must already point to <grafana_cloud_slug>.grafana.net."
  default     = ""
}

locals {
  valid_cname = "${var.grafana_cloud_slug}.grafana.net."
}

data "dns_cname_record_set" "cloud_domain_cname" {
  count = var.cloud_domain_host_grafana != "" ? 1 : 0
  host  = var.cloud_domain_host_grafana
}

resource "grafana_cloud_stack" "this" {
  name        = var.grafana_cloud_slug
  slug        = var.grafana_cloud_slug
  region_slug = var.grafana_cloud_region
  url         = var.cloud_domain_host_grafana != "" ? "https://${var.cloud_domain_host_grafana}" : null

  wait_for_readiness_timeout = "15m0s"

  lifecycle {
    # The AMI ID must refer to an AMI that contains an operating system
    # for the `x86_64` architecture.
    precondition {
      condition     = var.cloud_domain_host_grafana != "" ? one(data.dns_cname_record_set.cloud_domain_cname.*.cname) == local.valid_cname : true
      error_message = "If passed, the custom URL needs to exist and point to ${local.valid_cname}"
    }

  }
}
