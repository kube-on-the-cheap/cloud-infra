# Resources
resource "oci_identity_compartment" "object_storage" {
  compartment_id = var.tenancy_ocid
  name           = "ObjectStorage"
  description    = "Object Storage resource compartment"
  # defined_tags   = var.compartment_tags.defined
  # freeform_tags  = var.compartment_tags.freeform

  # lifecycle {
  #   ignore_changes = [
  #     defined_tags
  #   ]
  # }

}

# Outputs
output "object_storage_compartment_ocid" {
  value       = oci_identity_compartment.object_storage.id
  description = "The Object Storage compartmnent's OCID"
}
