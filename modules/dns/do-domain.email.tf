variable "email_domain_name" {
  type        = string
  description = "The email domain name."
}

## Domain creation and delegation

resource "digitalocean_domain" "email" {
  name = var.email_domain_name
}

data "digitalocean_records" "email_ns" {
  domain = digitalocean_domain.email.name
  filter {
    key    = "type"
    values = ["NS"]
  }
}

resource "digitalocean_record" "email_delegation" {
  count = 3

  domain = digitalocean_domain.cloud.id
  type   = "NS"
  name   = "oci" # FIXME: this sucks, should be a parameter
  value  = format("%s.", data.digitalocean_records.email_ns.records[count.index].value)
}

## Setting up SPF

resource "digitalocean_record" "email_spf" {
  domain = digitalocean_domain.email.id
  type   = "TXT"
  name   = "@"
  value  = var.email_spf_txt
}

variable "email_spf_txt" {
  description = "The TXT record to configure to set up SPF in the domain."
}

## Setting up DKIM

variable "email_dkim_cname" {
  type = object({
    selector = string
    dst      = string
  })
  description = "The CNAME to configure to set up DKIM in the domain."
}

resource "digitalocean_record" "email_dkim" {
  domain = digitalocean_domain.email.id
  type   = "CNAME"
  name   = format("%s._domainkey.%s.", var.email_dkim_cname.selector, var.email_domain_name)
  value  = var.email_dkim_cname.dst
}
