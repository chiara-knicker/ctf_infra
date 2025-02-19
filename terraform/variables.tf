// ------------- ORACLE -------------

variable "region" {
    type = string
    default = "uk-london-1"
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "private_key_path" {}
variable "fingerprint" {}

# instance
variable "compartment_id" {}
variable "availability_domain" {}
variable "ssh_public_key" {}

variable "ocpus" {
  description = "Number of OCPUs for the instance"
  type        = number
  default     = 1 # free tier
}

variable "memory_in_gbs" {
  description = "Amount of memory (GB) for the instance"
  type        = number
  default     = 1 # free tier
}

variable "image_id" {
    type = string
    default = "ocid1.image.oc1.uk-london-1.aaaaaaaaaghag4jvfj64zh6pnut7pihu3vke3tzihzp3mz2b5lifwoo3jqka" # Canonical-Ubuntu-24.04-Minimal-2024.10.08-0
}

variable "vm_shape" {
  type = string
  default = "VM.Standard.E2.1.Micro" # always free-eligible
}

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

variable "vm_machine_type_gcp_cluster" {
  type = string
  default = "e2-micro"
}

variable "cluster_node_count" {
  default = 3
}

// ------------- CLOUDFLARE -------------

# cloudflare
/*variable "cloudflare_api_token" {}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  default = ""
}*/