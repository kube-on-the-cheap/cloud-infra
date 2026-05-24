variable "homelab_domain_name" {
  description = "The domain used to host homelab resources"
}

resource "digitalocean_domain" "homelab" {
  name = var.homelab_domain_name

  lifecycle {
    precondition {
      condition     = strcontains(var.homelab_domain_name, var.domain_name)
      error_message = "The homelab domain must be part of the parent domain."
    }
  }
}

data "digitalocean_records" "homelab_ns" {
  domain = digitalocean_domain.homelab.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}
