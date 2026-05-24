variable "homelab_email_subdomain_name" {
  type        = string
  description = "The homelab email domain name."
}

## Domain creation and delegation

resource "digitalocean_domain" "homelab_email" {
  name = var.homelab_email_subdomain_name
  lifecycle {
    precondition {
      condition     = strcontains(var.homelab_email_subdomain_name, var.homelab_domain_name)
      error_message = "The homelab email domain must be part of the homelab domain."
    }
  }
}

data "digitalocean_records" "homelab_email_ns" {
  domain = digitalocean_domain.homelab_email.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}

resource "digitalocean_record" "homelab_email_delegation" {
  count = 3

  domain = digitalocean_domain.homelab.id
  type   = "NS"
  name   = trim(trimsuffix(var.homelab_email_subdomain_name, var.homelab_domain_name), ".")
  value  = format("%s.", data.digitalocean_records.homelab_email_ns.records[count.index].value)
  ttl    = 1800
}

## Setting up SPF

resource "digitalocean_record" "homelab_email_spf" {
  domain = digitalocean_domain.homelab_email.id
  type   = "TXT"
  name   = "@"
  value  = var.homelab_email_spf_txt
}

variable "homelab_email_spf_txt" {
  description = "The TXT record to configure to set up SPF in the homelab domain."
}

## Setting up DKIM

variable "homelab_email_dkim_cname" {
  type = object({
    selector = string
    dst      = string
  })
  description = "The CNAME to configure to set up DKIM in the homelab domain."
}

resource "digitalocean_record" "homelab_email_dkim" {
  domain = digitalocean_domain.homelab_email.id
  type   = "CNAME"
  name   = format("%s._domainkey.%s.", var.homelab_email_dkim_cname.selector, var.homelab_email_subdomain_name)
  value  = var.homelab_email_dkim_cname.dst
}
