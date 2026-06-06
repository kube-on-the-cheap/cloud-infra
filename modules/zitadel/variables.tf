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

variable "google_client_id" {
  description = "Client ID of the Google OAuth web-application client used for the Google IdP. Provided by Terragrunt via SOPS decrypt of google-oauth.sops.yaml."
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Client secret of the Google OAuth web-application client used for the Google IdP. Provided by Terragrunt via SOPS decrypt of google-oauth.sops.yaml."
  type        = string
  sensitive   = true
}
