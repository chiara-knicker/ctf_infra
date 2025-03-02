resource "google_container_cluster" "ctf_cluster" {
  name     = "ctf-challenges-cluster"
  location = var.region_gcp

  deletion_protection = false

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.ctf_cluster_network.name
  subnetwork = google_compute_subnetwork.ctf_cluster_subnet.name

  enable_shielded_nodes     = true   # Protect against kernel attacks
  networking_mode           = "VPC_NATIVE" # Enables VPC-native networking
  enable_intranode_visibility = true  # Improves network monitoring

  network_policy {
    enabled = true
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false # default
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true # default
    }
  }
}

resource "google_container_node_pool" "ctf_preemptible_nodes" {
  name       = "ctf-node-pool"
  location   = var.region_gcp
  cluster    = google_container_cluster.ctf_cluster.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.node_pool_machine_type
    disk_size_gb = var.disk_size
    disk_type    = var.disk_type
    image_type   = var.image_type

    tags = ["challenges"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot = true
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = "k8-admin@ucl-ctf-infra.iam.gserviceaccount.com" # google_service_account.k8-admin.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  # Enable autoscaling for the node pool
  autoscaling {
    min_node_count = 3
    max_node_count = 5  # Adjust based on the expected traffic
  }
}

resource "google_compute_network" "ctf_cluster_network" {
  name                    = "ctf-cluster-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ctf_cluster_subnet" {
  name          = "ctf-cluster-subnet"
  region        = var.region_gcp
  network       = google_compute_network.ctf_cluster_network.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "challenge_firewall" {
  name    = "challenges"
  network = google_compute_network.ctf_cluster_network.name 

  allow {
    protocol = "tcp"
    ports    = ["30000-30050"]
  }

  target_tags = ["challenges"]
  priority    = 1000
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]  # Allows traffic from any IP
}

resource "google_service_account" "k8s_admin" {
  account_id   = "k8s-admin"
  display_name = "Kubernetes Admin Service Account"
}

resource "google_project_iam_binding" "k8s_admin_role" {
  project = var.project_id
  role    = "roles/container.admin"

  members = [
    "serviceAccount:${google_service_account.k8s_admin.email}"
  ]
}