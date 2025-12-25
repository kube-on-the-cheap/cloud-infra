data "cloudflare_zone" "parent_domain" {
  filter = {
    name = var.domain_name
  }
}

resource "cloudflare_dns_record" "cloud_delegation" {
  # NOTE: this is a Terraform limitation - can't iterate on something discovered at runtime
  count = 3

  zone_id = data.cloudflare_zone.parent_domain.zone_id
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
