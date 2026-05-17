variable "resource_group_name" {
  description = "Name of resource group"
  type        = string
  default     = "my-resource-group"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "my-aks-cluster"
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "node_count" {
  description = "Initial number of nodes"
  type        = number
  default     = 2
}

variable "min_count" {
  description = "Minimum nodes (autoscale)"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum nodes (autoscale)"
  type        = number
  default     = 5
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
