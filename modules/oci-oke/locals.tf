locals {
  # CHEAT: this should have been a data source from another root module
  availability_domains = {
    "QjOL:EU-FRANKFURT-1-AD-1" = "ocid1.availabilitydomain.oc1..aaaaaaaalcdcbl7u6akbmkojxhrozpj2v7yavqqydkj3ytyjbt47lnoqnm2q"
    "QjOL:EU-FRANKFURT-1-AD-2" = "ocid1.availabilitydomain.oc1..aaaaaaaaa2artt5wizbqvwl3rgptylx2l7jqbnyv4dygcfvlrd3dphvi3mdq"
    # INFO: Since we have 2 nodes to allocate in 2 placements and forced to use 2 ad-specific subnets for load balancers, it's OK to lose an AD
    # "QjOL:EU-FRANKFURT-1-AD-3" = "ocid1.availabilitydomain.oc1..aaaaaaaaiifj24st3w4j7cowuo3pmqcuqwjapjv435vtjmgh5j7q3flguwna"
  }
}

# NOTE: can't do this because a data cannot be a source for a for_each
#
# data "oci_identity_availability_domains" "this" {
#   compartment_id = var.tenancy_ocid
# }

# output "ads" {
#   value = data.oci_identity_availability_domains.this
# }
