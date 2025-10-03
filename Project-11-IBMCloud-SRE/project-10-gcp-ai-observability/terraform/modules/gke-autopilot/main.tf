# GKE Autopilot cluster (HTTP LB enabled as required)
resource "google_container_cluster" "autopilot" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  enable_autopilot = true
  networking_mode  = "VPC_NATIVE"

  # Let Autopilot manage add-ons. Do NOT disable HTTP load balancing.
  addons_config {
    http_load_balancing { disabled = false }
    gke_backup_agent_config { enabled = false }
  }

  ip_allocation_policy {}

  release_channel {
    channel = "REGULAR"
  }

  deletion_protection = false
}

output "endpoint" { value = google_container_cluster.autopilot.endpoint }
output "ca_certificate" { value = google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate }
