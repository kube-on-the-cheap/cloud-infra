variable "cloud_email_subdomain_name" {
  type        = string
  description = "The cloud email domain name."
}

## Domain creation and delegation

resource "digitalocean_domain" "cloud_email" {
  name = var.cloud_email_subdomain_name
  lifecycle {
    precondition {
      condition     = strcontains(var.cloud_email_subdomain_name, var.cloud_domain_name)
      error_message = "The cloud email domain must be part of the cloud domain."
    }
  }
}

data "digitalocean_records" "cloud_email_ns" {
  domain = digitalocean_domain.cloud_email.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}

resource "digitalocean_record" "cloud_email_delegation" {
  count = 3

  domain = digitalocean_domain.cloud.id
  type   = "NS"
  name   = trim(trimsuffix(var.cloud_email_subdomain_name, var.cloud_domain_name), ".")
  value  = format("%s.", data.digitalocean_records.cloud_email_ns.records[count.index].value)
  ttl    = 1800
}

## Setting up SPF

resource "digitalocean_record" "cloud_email_spf" {
  domain = digitalocean_domain.cloud_email.id
  type   = "TXT"
  name   = "@"
  value  = var.cloud_email_spf_txt
}

variable "cloud_email_spf_txt" {
  description = "The TXT record to configure to set up SPF in the cloud domain."
}

## Setting up DKIM

variable "cloud_email_dkim_cname" {
  type = object({
    selector = string
    dst      = string
  })
  description = "The CNAME to configure to set up DKIM in the cloud domain."
}

resource "digitalocean_record" "cloud_email_dkim" {
  domain = digitalocean_domain.cloud_email.id
  type   = "CNAME"
  name   = format("%s._domainkey.%s.", var.cloud_email_dkim_cname.selector, var.cloud_email_subdomain_name)
  value  = var.cloud_email_dkim_cname.dst
}
