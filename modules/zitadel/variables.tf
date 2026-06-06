variable "zitadel_domain" {
  description = "Hostname of the self-hosted Zitadel instance."
  type        = string
  default     = "auth.cloud.blacksd.tech"
}

variable "zitadel_access_token" {
  description = "Personal access token of the Terraform machine user. Provided by Terragrunt via SOPS decrypt of zitadel-pat.sops.yaml."
  type        = string
  sensitive   = true
}
