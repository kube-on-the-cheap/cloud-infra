variable "domain_name" {
  description = "The parent OCI domain name"
}

variable "cloud_domain_name" {
  description = "The domain used to host cloud resources"
}

resource "digitalocean_domain" "cloud" {
  name = var.cloud_domain_name

  lifecycle {
    precondition {
      condition     = strcontains(var.cloud_domain_name, var.domain_name)
      error_message = "The cloud domain must be part of the parent domain."
    }
  }
}

data "digitalocean_records" "cloud_ns" {
  domain = digitalocean_domain.cloud.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}
