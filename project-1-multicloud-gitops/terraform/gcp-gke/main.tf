resource "google_container_cluster" "this" {
  name                  = var.cluster_name
  location              = var.region
  remove_default_node_pool = true
  initial_node_count    = 1
  networking_mode       = "VPC_NATIVE"
}
resource "google_container_node_pool" "primary" {
  name       = "primary"
  cluster    = google_container_cluster.this.name
  location   = var.region
  node_count = var.node_count
  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
output "cluster_name" { value = google_container_cluster.this.name }
