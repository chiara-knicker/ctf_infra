// ------------- ORACLE -------------

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

// ------------- GOOGLE -------------

provider "google" {
  project = var.project_id
  region  = var.region_gcp
  credentials = file(var.credentials_gcp)
}

// ------------- CLOUDFLARE -------------

/*
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}*/