variable "oke_node_pool_ocid" {
  description = "The OKE node pool's ID"
  type        = string
}

data "oci_containerengine_node_pool" "this" {
  node_pool_id = var.oke_node_pool_ocid
}

locals {
  node_ocids = {
    for n in data.oci_containerengine_node_pool.this.nodes : lower(split(":", n.availability_domain)[1]) => n.id if n.state == "ACTIVE"
  }
}
