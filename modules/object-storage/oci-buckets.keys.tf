resource "oci_identity_user" "bucket_user" {
  for_each = { for bucket_name, bucket_params in var.oci_buckets : bucket_name => bucket_params if bucket_params.create_s3_access_key }

  compartment_id = var.tenancy_ocid
  description    = "Robot user to access bucket ${each.key} via S3 Compatibility APIs"
  name           = format("s3_user_%s", each.key)

  email         = "s3_access+${each.key}@domain.local"
  freeform_tags = { "IAM-UserInfo.UserType" = "robot" }
}

resource "oci_identity_policy" "allow_user_bucket_access" {
  for_each = { for bucket_name, bucket_params in var.oci_buckets : bucket_name => bucket_params if bucket_params.create_s3_access_key }

  compartment_id = var.tenancy_ocid

  name        = "allow_${oci_identity_user.bucket_user[each.key].name}_write_bucket_${each.key}"
  description = "Policy to allow S3 access for user ${oci_identity_user.bucket_user[each.key].name} to access bucket ${each.key}"
  statements = [
    "Allow any-user to use buckets in compartment id ${oci_identity_compartment.object_storage.id} where all { target.bucket.name='${each.key}', request.user.id ='${oci_identity_user.bucket_user[each.key].name}' }",
    "Allow any-user to manage objects in compartment id ${oci_identity_compartment.object_storage.id} where all { target.bucket.name='${each.key}', request.user.id ='${oci_identity_user.bucket_user[each.key].name}' }"
  ]

  freeform_tags = { "IAM-UserInfo.UserType" = "robot" }
}

resource "oci_identity_customer_secret_key" "bucket_secret_key" {
  for_each = { for bucket_name, bucket_params in var.oci_buckets : bucket_name => bucket_params if bucket_params.create_s3_access_key }

  display_name = format("Access Key for S3 compatibility access for bucket %s", each.key)
  user_id      = one(oci_identity_user.bucket_user[*].id)
}

output "s3_credentials" {
  sensitive   = true
  description = "S3 Compatibility Layer credentials"
  value = { for bucket_name, bucket_secret_key in oci_identity_customer_secret_key.bucket_secret_key :
    (bucket_name) => {
      "ACCESS_KEY" = bucket_secret_key.id
      "SECRET_KEY" = bucket_secret_key.value
    }
  }
}
