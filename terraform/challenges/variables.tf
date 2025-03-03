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

variable "credentials_gcp" {
  type        = string
  description = "Path to the GCP service account JSON key"
}

variable "node_pool_machine_type" {
  type = string
  default = "e2-micro"
}

variable "node_count" {
  default = 1
}

variable "disk_size" {
  default = 30
}

variable "disk_type" {
  default = "pd-standard" # Standard persistent disk (cheaper but slower than SSD "pd-ssd")
}

variable "image_type" {
  default = "cos_containerd" # Uses Container-Optimized OS with containerd runtime
}

// ------------- CLOUDFLARE -------------

# cloudflare
/*variable "cloudflare_api_token" {}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  default = ""
}*/