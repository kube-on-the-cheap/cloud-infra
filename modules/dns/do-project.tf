resource "digitalocean_project" "kotc" {
  name        = var.project_name
  description = "All resources for KOTC cluster on DigitalOcean"
  purpose     = "DNS Management"
  environment = "Production"
}

resource "digitalocean_project_resources" "kotc" {
  project = digitalocean_project.kotc.id
  resources = [
    digitalocean_domain.cloud.urn,
    digitalocean_domain.email.urn
  ]
}
