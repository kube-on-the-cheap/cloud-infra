variable "oci_buckets" {
  description = "A map of a buckets to create in Oracle Cloud. Bucket name is the key."
  type = map(object({
    # Standard, Archive
    storage_tier : string,
    # Disabled, Enabled, Suspended
    versioning : string,
    access_type : optional(string, "NoPublicAccess"),
    auto_tiering : optional(string, "Disabled"),
    object_events_enabled : optional(bool, false),
    retention : optional(string),
    lifecycle : optional(string),
    create_s3_access_key : optional(bool, false),
    store_s3_credentials_in_vault : optional(bool, true),
    grant_oke_workers_access : optional(bool, false)
  }))

  # https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm#bucketnames
  validation {
    condition     = alltrue([for bucket_name in keys(var.oci_buckets) : length(bucket_name) >= 4 && length(bucket_name) <= 256])
    error_message = "All bucket names must be within the Oracle Cloud naming convention (between 4 and 256 chars)."
  }
  validation {
    condition     = alltrue([for bucket_params in values(var.oci_buckets) : contains(["Standard", "Archive"], bucket_params.storage_tier)])
    error_message = "Storage tier must be either 'Standard' or 'Archive'."
  }
  validation {
    condition     = alltrue([for bucket_params in values(var.oci_buckets) : contains(["Disabled", "Enabled", "Suspended"], bucket_params.versioning)])
    error_message = "Versioning must be either 'Disabled', 'Enabled' at creation, 'Suspended' is allowed on updates. "
  }
  validation {
    condition     = alltrue([for bucket_params in values(var.oci_buckets) : contains(["NoPublicAccess", "ObjectRead", "ObjectReadWithoutList"], bucket_params.access_type)])
    error_message = "The type of public access enabled on this bucket. Allowed values are 'NoPublicAccess', 'ObjectRead', 'ObjectReadWithoutList'."
  }
  validation {
    condition     = alltrue([for bucket_params in values(var.oci_buckets) : contains(["InfrequentAccess", "Disabled"], bucket_params.auto_tiering)])
    error_message = "Auto-tiering for bucket objects. Can be 'Disabled' or 'InfrequentAccess'."
  }
  # INFO: I'm sorry for this monstrosity, but it's easier than the alternatives
  validation {
    condition = alltrue([
      for bucket_params in values(var.oci_buckets) : (
        length(try(split(",", bucket_params.lifecycle)[0], "")) > 0 &&
        length(try(split(",", bucket_params.lifecycle)[1], "")) > 1
      ) if bucket_params.lifecycle != null
    ])
    error_message = "If the lifecycle rule is not null, it should be composed by '<quantity><time duration>,<action>'. Space trimming and casing will be adjusted."
  }
}

variable "oke_iam_dynamic_group_workers_name" {
  type        = string
  description = "The OKE IAM dynamic group name for workers"
}
