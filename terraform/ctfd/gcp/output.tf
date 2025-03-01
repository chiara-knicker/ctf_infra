// ------------- GOOGLE -------------

output "ctfd_instance_ip" {
  value = google_compute_instance.ctfd_instance.network_interface[0].access_config[0].nat_ip
}

// ------------- CLOUDFLARE -------------

/*output "ctfd_dns" {
  value = cloudflare_record.ctfd.hostname
}*/