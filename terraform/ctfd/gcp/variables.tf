// ------------- GOOGLE -------------

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

# Region and Zone
variable "region_gcp" {
  type    = string
  default = "europe-west2"
}

variable "zone_gcp" {
  type    = string
  default = "europe-west2-a"
}

# Instance Configuration
variable "ssh_public_key_gcp" {
  type        = string
  description = "Path to SSH public key file"
}

variable "vm_machine_type_gcp" {
  type    = string
  default = "e2-micro"
}

variable "image_gcp" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts" # Use Ubuntu 22.04 LTS
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}

variable "credentials_gcp" {
  type        = string
  description = "Path to the GCP service account JSON key"
}

// ------------- CLOUDFLARE -------------

variable "cloudflare_api_token" {}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
}

variable "subdomain" {}