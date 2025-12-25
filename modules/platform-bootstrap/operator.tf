variable "flux_operator_version" {
  type        = string
  description = "The Flux Operator version to install"
}

resource "helm_release" "flux_operator" {
  name       = "flux-operator"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"

  chart            = "flux-operator"
  create_namespace = true
  wait             = true
  version          = var.flux_operator_version

  lifecycle {
    precondition {
      condition     = one(data.kubernetes_namespace.kube_system.metadata.*.uid) != null
      error_message = "Unable to get the kube-system namespace. Check the connection to the API Server and/or the permissions for the user in your kubeconfig."
    }
  }
}
