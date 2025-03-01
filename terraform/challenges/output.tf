// ------------- GOOGLE -------------

output "challenges_cluster_endpoint" {
  value = google_container_cluster.ctf_cluster.endpoint
}

output "access_token" {
  value = data.google_client_config.default.access_token
  sensitive = true
}

output "cluster_ca_cert" {
  value = google_container_cluster.ctf_cluster.master_auth[0].cluster_ca_certificate
  sensitive = true
}

// ------------- CLOUDFLARE -------------

/*output "ctfd_dns" {
  value = cloudflare_record.ctfd.hostname
}*/