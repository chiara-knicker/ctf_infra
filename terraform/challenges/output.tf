// ------------- GOOGLE -------------

output "ctf_cluster_endpoint" {
  value = google_container_cluster.ctf_cluster.endpoint
}

/*output "access_token" {
  value = data.google_client_config.default.access_token
  sensitive = true
}*/

output "cluster_ca_cert" {
  value = google_container_cluster.ctf_cluster.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "k8s_deployer_access_token" {
  value     = data.google_service_account_access_token.k8s_deployer_access_token.access_token
  sensitive = true
}

output "k8s_deployer_key" {
  value     = google_service_account_key.k8s_deployer_key.private_key
  sensitive = true 
}

// ------------- CLOUDFLARE -------------

/*output "ctfd_dns" {
  value = cloudflare_record.ctfd.hostname
}*/