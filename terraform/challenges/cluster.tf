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

  enable_shielded_nodes     = true          # Protect against kernel attacks
  networking_mode           = "VPC_NATIVE"  # Enables VPC-native networking
  enable_intranode_visibility = true        # Improves network monitoring

  network_policy {
    enabled = true
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
    service_account = google_service_account.k8s_node.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
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
  ip_cidr_range = "10.0.0.0/24"
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
  source_ranges = ["0.0.0.0/0"] 
}

# Service account used by nodes
resource "google_service_account" "k8s_node" {
  account_id   = "k8s-node"
  display_name = "Kubernetes Node Service Account"
}

# Service account for deploying challenges to cluster
resource "google_service_account" "k8s_deployer" {
  account_id   = "k8s-deployer"
  display_name = "Kubernetes Deployer Service Account"
}

resource "google_project_iam_binding" "k8s_deployer_container_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  members = [
    "serviceAccount:${google_service_account.k8s_deployer.email}"
  ]
}

resource "google_project_iam_binding" "k8s_deployer_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  members = [
    "serviceAccount:${google_service_account.k8s_deployer.email}"
  ]
}

resource "google_project_iam_binding" "k8s_deployer_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  members = [
    "serviceAccount:${google_service_account.k8s_deployer.email}"
  ]
}

resource "google_service_account_key" "k8s_deployer_key" {
  service_account_id = google_service_account.k8s_deployer.id
}

data "google_service_account_access_token" "k8s_deployer_access_token" {
  target_service_account = google_service_account.k8s_deployer.email
  scopes                = ["cloud-platform"]
}