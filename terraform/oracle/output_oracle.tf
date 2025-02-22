// ------------- ORACLE -------------

output "ctfd_instance_ip" {
  value = oci_core_instance.ctfd_instance.public_ip
}

// ------------- CLOUDFLARE -------------

/*output "ctfd_dns" {
  value = cloudflare_record.ctfd.hostname
}*/