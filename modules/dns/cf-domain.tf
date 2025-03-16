variable "cf_account_id" {
  type        = string
  description = "The Cloudflare Account ID"
}

resource "cloudflare_zone" "parent_domain" {
  account = {
    id = var.cf_account_id
  }
  name = var.parent_domain
  type = "full"
}

resource "cloudflare_dns_record" "cloud_delegation" {
  # NOTE: this is a Terraform limitation - can't iterate on something discovered at runtime
  count = 3

  zone_id = cloudflare_zone.parent_domain.id
  comment = "Subdomain NS${count.index + 1} delegation record"
  content = data.digitalocean_records.cloud_ns.records[count.index].value
  name    = local.subdomain
  proxied = false
  settings = {
    ipv4_only = true
    ipv6_only = false
  }
  tags = []
  ttl  = 1
  type = "NS"
}
