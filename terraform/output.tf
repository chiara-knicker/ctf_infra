output "ctfd_instance_ip" {
  value = oci_core_instance.ctfd_instance.public_ip
}

/*output "challenges_instance_ip" {
  value = oci_core_instance.challenges_instance.public_ip
}*/