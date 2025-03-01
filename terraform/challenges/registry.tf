resource "google_artifact_registry_repository" "ctf_docker_registry" {
  provider      = google
  location      = var.region_gcp
  repository_id = "ctf-docker-registry"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false  # Optional: prevents overwriting tags
  }
}