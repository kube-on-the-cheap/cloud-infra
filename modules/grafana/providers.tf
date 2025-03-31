
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~>3.22"
    }
    oci = {
      source  = "oracle/oci"
      version = "~>6.26"
    }
  }
  backend "gcs" {}
}

provider "grafana" {
}
