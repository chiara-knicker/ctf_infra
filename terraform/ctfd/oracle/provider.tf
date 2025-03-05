// ------------- ORACLE -------------

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

// ------------- CLOUDFLARE -------------

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"  # Adjust to the latest stable version if needed
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}