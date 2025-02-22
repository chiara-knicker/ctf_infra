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

// ------------- CLOUDFLARE -------------

# cloudflare
/*variable "cloudflare_api_token" {}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  default = ""
}*/