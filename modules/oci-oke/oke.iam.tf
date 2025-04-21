resource "oci_identity_dynamic_group" "all_oke_clusters" {
  # Dynamic group can only be created in the tenancy compartment
  compartment_id = var.tenancy_ocid

  name          = "all_oke_clusters_compartment_${lower(oci_identity_compartment.oke.name)}"
  description   = "Dynamic group containing all OKE Clusters running in the '${oci_identity_compartment.oke.name}' Compartment"
  matching_rule = "ALL {resource.type = 'cluster', resource.compartment.id = '${oci_identity_compartment.oke.id}'}"
}

resource "oci_identity_dynamic_group" "all_oke_workers" {
  # Dynamic group can only be created in the tenancy compartment
  compartment_id = var.tenancy_ocid

  name          = "all_oke_workers_compartment_${lower(oci_identity_compartment.oke.name)}"
  description   = "Dynamic group containing all OKE worker nodes running in the '${oci_identity_compartment.oke.name}' Compartment"
  matching_rule = "ALL {instance.compartment.id = '${oci_identity_compartment.oke.id}'}"
}

output "oke_iam_dynamic_group_workers_name" {
  value       = oci_identity_dynamic_group.all_oke_workers.name
  description = "All OKE workers in the dedicated compartment"
}
