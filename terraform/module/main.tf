resource "google_container_cluster" "primary_jm" {
  name     = var.cluster_name
  location = var.region
  initial_node_count = var.initial_node_count
  deletion_protection = false
}
