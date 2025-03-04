variable "region" {
  description = "The GCP region where the cluster will be deployed"
  type        = string
  default     = "us-east1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "jm-gke-cluster"
}

variable "initial_node_count" {
  description = "The name of the GKE cluster"
  type        = number
  default     = 1
}
