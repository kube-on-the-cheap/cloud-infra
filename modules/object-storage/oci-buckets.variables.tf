variable "oci_buckets" {
  type = map(object({
    # Standard, Archive
    storage_tier : string
    # Disabled, Enabled, Suspended
    versioning : string
    access_type : optional(string, "NoPublicAccess")
    auto_tiering : optional(string, "Disabled"),
    object_events_enabled : optional(bool, false),
    retention : optional(string),
    create_s3_access_key : optional(bool, false)
  }))
  description = "A list of a buckets to create"

  # https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm#bucketnames
  validation {
    condition     = alltrue([for bucket_name in keys(var.oci_buckets) : length(bucket_name) >= 4 && length(bucket_name) <= 256])
    error_message = "All bucket names must be within the Oracle Cloud naming convention (between 4 and 256 chars)."
  }
  validation {
    condition     = alltrue([for bucket_params in values(var.oci_buckets) : contains(["Standard", "Archive"], bucket_params.storage_tier)])
    error_message = "Storage tier must be either 'Standard' or 'Archive'. "
  }
  validation {
    condition     = alltrue([for bucket_params in values(var.oci_buckets) : contains(["Disabled", "Enabled", "Suspended"], bucket_params.versioning)])
    error_message = "Versioning must be either 'Disabled', 'Enabled' or 'Suspended'. "
  }
  # validation {
  #   condition     = retention
  #   error_message = "Check that the retention is in format <amount><unit>"
  # }
  # validation {
  #   condition     = access_type
  #   error_message = "The type of public access enabled on this bucket. NoPublicAccess, ObjectRead, ObjectReadWithoutList"
  # }
  # validation {
  #   condition     = auto_tiering
  #   error_message = "Disabled or Enabled"
  # }
}

variable "oke_iam_dynamic_group_workers_name" {
  type        = string
  description = "The OKE IAM dynamic group name for workers"
}

# variable "bucket_versioning" {
#   type        = string
#   description = "Bucket versioning status"
#   validation {
#     condition     = contains(["Disabled", "Enabled", "Suspended"], var.bucket_versioning)
#     error_message = "Storage tier must be either \"Disabled\", \"Enabled\", \"Suspended\". "
#   }
# }

# variable "bucket_create_s3_access_key" {
#   type        = bool
#   description = "(optional) describe your variable"
#   default     = false
# }

# variable "oci_kms_id" {
#   type        = string
#   description = "The OCI KMS master encryption key id to use."
# }
