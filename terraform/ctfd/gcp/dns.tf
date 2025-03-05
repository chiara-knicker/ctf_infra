// ------------- CLOUDFLARE -------------

resource "cloudflare_record" "ctfd" {
  zone_id = var.cloudflare_zone_id                      # The Cloudflare zone ID for your domain
  name    = "ctfd"                                      # Subdomain (e.g., ctfd.example.com)
  value   = google_compute_instance.ctfd_instance.network_interface[0].access_config[0].nat_ip   # VM's public IP address
  type    = "A"                                         # DNS record type (A record for IP address)
  ttl     = 1                                           # TTL (Time to live), can be adjusted
}