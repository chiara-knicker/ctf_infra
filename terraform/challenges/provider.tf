// ------------- GOOGLE -------------
/*
resource "google_service_account" "k8-admin" {
  account_id   = "k8-admin"
  display_name = "Kubernetes Admin Service Account"
}
*/
provider "google" {
  project = var.project_id
  region  = var.region_gcp
  credentials = file(var.credentials_gcp)
}

data "google_client_config" "default" {
}

# TODO: permission denied
/*data "google_service_account_access_token" "sa_token" {
  target_service_account = "k8-admin@ucl-ctf-infra.iam.gserviceaccount.com"
  scopes                = ["cloud-platform", "userinfo.email"]
}

output "access_token_k8" {
  value     = data.google_service_account_access_token.sa_token.access_token
  sensitive = true
}*/


// ------------- CLOUDFLARE -------------

/*
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}*/