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
    ssh-keys  = "${var.ssh_user}:${file(var.ssh_public_key_gcp)}"
    startup-script = file("scripts/ctfd-init.sh")
  }
}

resource "google_artifact_registry_repository" "ctf_docker_registry" {
  provider      = google
  location      = var.region_gcp
  repository_id = "ctf-docker-registry"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false  # Optional: prevents overwriting tags
  }
}

/*resource "google_service_account" "terraform" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}*/

resource "google_container_cluster" "ctf_cluster" {
  name     = "ctf-challenges-cluster"
  location = var.region_gcp

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "ctf_preemptible_nodes" {
  name       = "ctf-node-pool"
  location   = var.region_gcp
  cluster    = google_container_cluster.ctf_cluster.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.node_pool_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    #service_account = google_service_account.terraform.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}