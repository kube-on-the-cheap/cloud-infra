# Terraform Config
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~>5"
    }
  }
  backend "gcs" {}
}

# Providers
provider "digitalocean" {
}

provider "cloudflare" {
}
