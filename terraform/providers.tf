terraform {
  required_version = ">= 1.5.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.110.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  # The devbox PVE box serves a self-signed certificate.
  insecure = var.proxmox_insecure
}

# Authentication comes from CLOUDFLARE_API_TOKEN in the environment.
provider "cloudflare" {}
