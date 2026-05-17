variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west1-b"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "my-gke-cluster"
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "n1-standard-1"
}

variable "initial_node_count" {
  description = "Initial number of nodes"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum nodes (autoscale)"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes (autoscale)"
  type        = number
  default     = 5
}

variable "preemptible" {
  description = "Use preemptible instances (cheaper)"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
