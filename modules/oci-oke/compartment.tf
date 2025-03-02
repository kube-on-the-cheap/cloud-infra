# Resources
resource "oci_identity_compartment" "oke" {
  compartment_id = var.tenancy_ocid
  name           = "OKE"
  description    = "Managed Kubernetes resource compartment"
  # defined_tags   = var.compartment_tags.defined
  # freeform_tags  = var.compartment_tags.freeform

  # lifecycle {
  #   ignore_changes = [
  #     defined_tags
  #   ]
  # }

}

# Outputs
output "oke_compartment_ocid" {
  value       = oci_identity_compartment.oke.id
  description = "The OKE compartmnent's OCID"
}
