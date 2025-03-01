resource "google_container_cluster" "ctf_cluster" {
  name     = "ctf-challenges-cluster"
  location = var.region_gcp

  deletion_protection = false

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

    tags = ["challenges"]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = "k8-admin@ucl-ctf-infra.iam.gserviceaccount.com" # google_service_account.k8-admin.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_compute_firewall" "challenge_firewall" {
  name    = "challenges"
  network = "default"  # Change this if you're using a different VPC network

  allow {
    protocol = "tcp"
    ports    = ["30000-30050"]
  }

  target_tags = ["challenges"]
  priority    = 1000

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]  # Allows traffic from any IP. Change this for security.
}
