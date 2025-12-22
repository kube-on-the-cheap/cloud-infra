variable "project_name" {
  type        = string
  description = "The DigitalOcean project name to create the domain in"
}

data "digitalocean_project" "kotc" {
  name = var.project_name
}

resource "digitalocean_project_resources" "kotc" {
  project = data.digitalocean_project.kotc.id
  resources = [
    digitalocean_domain.cloud.urn,
    digitalocean_domain.email.urn
  ]
}
