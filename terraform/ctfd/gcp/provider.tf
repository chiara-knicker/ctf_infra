// ------------- GOOGLE -------------

provider "google" {
  project = var.project_id
  region  = var.region_gcp
  credentials = file(var.credentials_gcp)
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