// ------------- CLOUDFLARE -------------

/*
resource "cloudflare_record" "ctfd" {
  zone_id = var.cloudflare_zone_id                      # The Cloudflare zone ID for your domain
  name    = "ctfd"                                      # Subdomain (e.g., ctfd.example.com)
  value   = oci_core_instance.ctfd_instance.public_ip   # VM's public IP address
  type    = "A"                                         # DNS record type (A record for IP address)
  ttl     = 300                                         # TTL (Time to live), can be adjusted
}*/

// ------------- NAMECHEAP -------------

/*resource "namecheap_record" "ctfd_record" {
  domain  = "uclcybersoc.org"          
  host    = "ctfd"        
  type    = "A"   
  value   = google_compute_instance.ctfd_instance.network_interface[0].access_config[0].nat_ip
  ttl     = 300  
}*/

/*resource "namecheap_record" "challenge_record" {
  domain  = "uclcybersoc.org"   
  host    = "challenge"     
  type    = "A"      
  value   = google_compute_instance.challenges_instance.network_interface[0].access_config[0].nat_ip
  ttl     = 300     
}*/