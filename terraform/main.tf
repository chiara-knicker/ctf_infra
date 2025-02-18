// ------------- ORACLE -------------

# Create the VCN
resource "oci_core_virtual_network" "ctf_vcn" {
  compartment_id = var.compartment_id
  display_name   = "ctf-vcn"
  cidr_block     = "10.0.0.0/16"
}

# Create the public subnet
resource "oci_core_subnet" "ctf_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-public-subnet"
  cidr_block     = "10.0.0.0/24"
  route_table_id = oci_core_route_table.ctf_public_route_table.id
  security_list_ids = [
    oci_core_security_list.ctf_public_security_list.id
  ]
  # availability_domain = var.availability_domain # regional if omitted
  prohibit_public_ip_on_vnic = false # Allows public IP assignment
}

# Create the internet gateway
resource "oci_core_internet_gateway" "ctf_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-internet-gateway"
}

# Create the route table for public subnet
resource "oci_core_route_table" "ctf_public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-public-route-table"
  
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id  = oci_core_internet_gateway.ctf_internet_gateway.id
  }
}

# Security List (Firewall Rules)
resource "oci_core_security_list" "ctf_public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.ctf_vcn.id
  display_name   = "ctf-public-security-list"
  
  ingress_security_rules {
    protocol    = "6"   # TCP
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "22" # SSH
        max = "22"
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "80" # HTTP
        max = "80"
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "8000" # CTFd port
        max = "8000"
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "443" # HTTPS
        max = "443"
    }
  }
  
  ingress_security_rules {
    protocol              = "6" 
    source                = "0.0.0.0/0"  # Allow from anywhere
    tcp_options {
        min = "12345" # netcat ports
        max = "12355"
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"  # Allow all outbound traffic
  }
}

# Create instance
resource "oci_core_instance" "ctfd_instance" {
    compartment_id      = var.compartment_id
    availability_domain = var.availability_domain
    shape               = var.vm_shape
    display_name        = "ctfd-instance"

    shape_config {
        ocpus = var.ocpus
        memory_in_gbs = var.memory_in_gbs
    }

    source_details {
        source_type = "image"
        source_id = var.image_id
    }

    create_vnic_details {
        subnet_id = oci_core_subnet.ctf_public_subnet.id
        assign_public_ip = true
    }
    
    metadata = {
        ssh_authorized_keys = file(var.ssh_public_key)
        user_data           = filebase64("scripts/ctfd-init.sh")  # Script for setting up the VM
    }
}

/*
resource "oci_core_instance" "challenges_instance" {
    compartment_id      = var.compartment_id
    availability_domain = var.availability_domain
    shape               = var.vm_shape
    display_name        = "challenges-instance"

    create_vnic_details {
        subnet_id = oci_core_subnet.ctf_public_subnet.id
        assign_public_ip = true
    }

    create_vnic_details {
        subnet_id = oci_core_subnet.ctf_public_subnet.id
        assign_public_ip = true
    }

    metadata = {
        ssh_authorized_keys = file(var.ssh_public_key)
        user_data           = filebase64("scripts/cloud-init-k8s.sh")  # Script for setting up the VM
    }
}
*/

// ------------- GOOGLE -------------

# Create the VPC network
resource "google_compute_network" "ctf_vpc" {
  name                    = "ctf-vpc"
  auto_create_subnetworks = false
}

# Create the subnet
resource "google_compute_subnetwork" "ctf_public_subnet" {
  name          = "ctf-public-subnet"
  network       = google_compute_network.ctf_vpc.id
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region_gcp
}

# Firewall Rules (Equivalent to Security Lists in OCI)
resource "google_compute_firewall" "allow_ingress" {
  name    = "ctf-firewall"
  network = google_compute_network.ctf_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8000", "12345-12355"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create the Compute Instance for CTFd
resource "google_compute_instance" "ctfd_instance" {
  name         = "ctfd-instance"
  machine_type = var.vm_machine_type_gcp
  zone         = var.zone_gcp

  boot_disk {
    initialize_params {
      image = var.image_gcp
    }
  }

  network_interface {
    network    = google_compute_network.ctf_vpc.id
    subnetwork = google_compute_subnetwork.ctf_public_subnet.id
    access_config {
      # Assigns a public IP
    }
  }

  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_public_key_gcp)}"
    startup-script = file("scripts/ctfd-init.sh")
  }
}

# Create the Compute Instance for Challenges (Commented out for now)
# resource "google_compute_instance" "challenges_instance" {
#   name         = "challenges-instance"
#   machine_type = var.vm_machine_type_gcp
#   zone         = var.zone_gcp
# 
#   boot_disk {
#     initialize_params {
#       image = var.image_gcp
#     }
#   }
# 
#   network_interface {
#     network    = google_compute_network.ctf_vpc.id
#     subnetwork = google_compute_subnetwork.ctf_public_subnet.id
#     access_config {
#       # Assigns a public IP
#     }
#   }
# 
#   metadata = {
#     ssh-keys  = "ubuntu:${file(var.ssh_public_key_gcp)}"
#     startup-script = file("scripts/cloud-init-k8s.sh")
#   }
# }

// ------------- CLOUDFLARE -------------

/*
resource "cloudflare_record" "ctfd" {
  zone_id = var.cloudflare_zone_id                      # The Cloudflare zone ID for your domain
  name    = "ctfd"                                      # Subdomain (e.g., ctfd.example.com)
  value   = oci_core_instance.ctfd_instance.public_ip   # VM's public IP address
  type    = "A"                                         # DNS record type (A record for IP address)
  ttl     = 300                                         # TTL (Time to live), can be adjusted
}*/