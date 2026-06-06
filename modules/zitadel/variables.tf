variable "zitadel_domain" {
  description = "Hostname of the self-hosted Zitadel instance."
  type        = string
  default     = "auth.cloud.blacksd.tech"
}

variable "zitadel_jwt_profile_json" {
  description = "Service-account JSON key (whole document, inline) for the Terraform machine user. Provided by Terragrunt via SOPS decrypt of zitadel-key.sops.json."
  type        = string
  sensitive   = true
}
