resource "grafana_cloud_stack" "this" {
  name        = var.gc_stack_slug
  slug        = var.gc_stack_slug
  region_slug = var.gc_region

  wait_for_readiness_timeout = "15m0s"
}
