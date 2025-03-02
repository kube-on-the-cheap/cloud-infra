terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
  backend "gcs" {}
}

variable "session_data_dir" {
  description = "The directory to read session data from"
  type        = string

  validation {
    condition     = fileexists(format("%s/%s", var.session_data_dir, local.kubeconfig_local_path))
    error_message = "The session_data_dir doesn't point to a directory hosting the .kube/config file"
  }
}

locals {
  kubeconfig_local_path = "control-plane/.kube/config"
  kubeconfig_path       = format("%s/%s", var.session_data_dir, local.kubeconfig_local_path)
}

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = local.kubeconfig_path
  }
}

data "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

# check "kube_get_namespace" {
#   data "kubernetes_namespace" "kube_system" {
#     metadata {
#       name = "kube-system"
#     }
#   }

#   assert {
#     condition     = one(data.kubernetes_namespace.kube_system.metadata.*.uid) != null
#     error_message = "Unable to get the kube-system namespace. Check the connection to the API Server and/or the permissions for the user in your kubeconfig."
#   }
# }
