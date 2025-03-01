// ------------- CLOUDFLARE -------------

/*
resource "cloudflare_record" "ctfd" {
  zone_id = var.cloudflare_zone_id                      # The Cloudflare zone ID for your domain
  name    = "ctfd"                                      # Subdomain (e.g., ctfd.example.com)
  value   = oci_core_instance.ctfd_instance.public_ip   # VM's public IP address
  type    = "A"                                         # DNS record type (A record for IP address)
  ttl     = 300                                         # TTL (Time to live), can be adjusted
}*/
