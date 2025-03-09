variable "parent_domain" {
  type        = string
  description = "The parent domain to delegate the subdomain to"
}

variable "project_name" {
  type        = string
  description = "The DigitalOcean project name to create the domain in"
}

resource "digitalocean_project" "kotc" {
  name        = var.project_name
  description = "All resources for KOTC cluster on DigitalOcean"
  purpose     = "DNS Management"
  environment = "Production"
}

resource "digitalocean_project_resources" "kotc" {
  project = digitalocean_project.kotc.id
  resources = [
    digitalocean_domain.cloud.urn
  ]
}

resource "digitalocean_domain" "cloud" {
  name = format("cloud.%s", var.parent_domain)
}

data "digitalocean_records" "cloud_ns" {
  domain = digitalocean_domain.cloud.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}

output "cloud_domain_ns" {
  value       = [for r in data.digitalocean_records.cloud_ns.records : r.value]
  description = "The nameservers for the delegated zone. Add these records as NS type records in the parent domain to perform zone delegation."
}
