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
    ports    = ["22", "80", "443", "8000"]
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
    ssh-keys  = "${var.ssh_user}:${file(var.ssh_public_key_gcp)}"
    startup-script = file("scripts/ctfd-init.sh")
  }
}