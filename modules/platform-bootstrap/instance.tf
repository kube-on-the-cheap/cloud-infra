variable "sync" {
  description = "The info of the Git repository to sync with Flux"
  type = object({
    repo = string
    path = string
    ref  = optional(string, "main")
  })
}

variable "components" {
  description = "The components to install"
  type        = list(string)
  default = [
    "source-controller",
    "kustomize-controller",
    "helm-controller",
    "notification-controller"
  ]
}

variable "flux_version" {
  description = "The version of Flux to install"
  type        = string
}

resource "helm_release" "flux_instance" {
  name       = "flux"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"

  chart = "flux-instance"

  depends_on = [
    helm_release.flux_operator
  ]

  values = [
    templatefile("templates/components.yaml.tftpl", {
      components = var.components
    }),
    templatefile("templates/distribution.yaml.tftpl", {
      flux_version = var.flux_version
    }),
    templatefile("templates/sync.yaml.tftpl", {
      repo = var.sync.repo
      path = var.sync.path
      ref  = var.sync.ref
    }),
  ]

  lifecycle {
    precondition {
      condition     = one(data.kubernetes_namespace.kube_system.metadata.*.uid) != null
      error_message = "Unable to get the kube-system namespace. Check the connection to the API Server and/or the permissions for the user in your kubeconfig."
    }
  }
}
