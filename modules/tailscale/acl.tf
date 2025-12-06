resource "tailscale_acl" "this" {
  # language=JSON
  acl = file("${path.module}/config/tailnet_acl.hujson")
}
