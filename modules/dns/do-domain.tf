variable "parent_domain" {
  type        = string
  description = "The parent domain to delegate the subdomain to"
}

variable "project_name" {
  type        = string
  description = "The DigitalOcean project name to create the domain in"
}

locals {
  subdomain = "cloud"
}

resource "digitalocean_domain" "cloud" {
  name = "${local.subdomain}.${var.parent_domain}"
}

data "digitalocean_records" "cloud_ns" {
  domain = digitalocean_domain.cloud.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}

variable "grafana_cloud_slug" {
  description = "Grafana Cloud slug used to create the corresponding Stack."
  type        = string
}

resource "digitalocean_record" "grafana" {
  domain = digitalocean_domain.cloud.name
  type   = "CNAME"
  ttl    = 1800
  name   = "grafana"
  value  = "${var.grafana_cloud_slug}.grafana.net."
}

# INFO: not really required, since we do delegation with a resource
#
# output "cloud_domain_ns" {
#   value       = [for r in data.digitalocean_records.cloud_ns.records : r.value]
#   description = "Nameservers for the delegated zone. Add these records as NS type records in the parent domain to perform zone delegation."
# }

output "cloud_domain_host_grafana" {
  value       = digitalocean_record.grafana.fqdn
  description = "Grafana Cloud custom domain's FQDN."
}
