// ------------- ORACLE -------------

output "ctfd_instance_ip" {
  value = oci_core_instance.ctfd_instance.public_ip
}

/*output "challenges_instance_ip" {
  value = oci_core_instance.challenges_instance.public_ip
}*/

// ------------- GOOGLE -------------

output "ctfd_instance_ip_gcp" {
  value = google_compute_instance.ctfd_instance.network_interface[0].access_config[0].nat_ip
}

/*output "challenges_instance_ip" {
  value = google_compute_instance.challenges_instance.network_interface[0].access_config[0].nat_ip
}*/

// ------------- CLOUDFLARE -------------

/*output "ctfd_dns" {
  value = cloudflare_record.ctfd.hostname
}*/