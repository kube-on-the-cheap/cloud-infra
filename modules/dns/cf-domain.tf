variable "cf_account_id" {
  type        = string
  description = "The Cloudflare Account ID"
}

variable "domain_name" {
  type        = string
  description = "The parent domain to delegate the subdomain to"
}

resource "cloudflare_zone" "parent_domain" {
  account = {
    id = var.cf_account_id
  }
  name = var.domain_name
  type = "full"
}

resource "cloudflare_dns_record" "cloud_delegation" {
  # NOTE: this is a Terraform limitation - can't iterate on something discovered at runtime
  count = 3

  zone_id = cloudflare_zone.parent_domain.id
  comment = "Subdomain NS${count.index + 1} delegation record"
  content = data.digitalocean_records.cloud_ns.records[count.index].value
  name    = var.cloud_domain_name
  proxied = false
  settings = {
    ipv4_only = true
    ipv6_only = false
  }
  tags = []
  ttl  = 1
  type = "NS"
}
