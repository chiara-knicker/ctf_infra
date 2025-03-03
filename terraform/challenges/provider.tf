// ------------- GOOGLE -------------

provider "google" {
  project = var.project_id
  region  = var.region_gcp
  credentials = file(var.credentials_gcp)
}

#data "google_client_config" "default" {}

// ------------- CLOUDFLARE -------------

/*
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}*/