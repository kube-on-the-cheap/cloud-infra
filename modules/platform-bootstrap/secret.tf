variable "secret_key" {
  description = "The secret decryption key"
  type        = string
  sensitive   = true
}

resource "kubernetes_secret" "encryption_key" {
  metadata {
    name      = "encryption-key"
    namespace = "flux-system"
  }

  data = {
    "age.agekey" = var.secret_key
  }

  # NOTE: this will also create the namespace
  depends_on = [helm_release.flux_instance]
}
