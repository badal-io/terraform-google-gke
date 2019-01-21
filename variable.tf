variable "module_dependency" {
  type        = "string"
  default     = ""
  description = "This is a dummy value to create module dependency"
}

variable "name" {
    description = "The name of the bucket."
    type        = "string"
}

variable "project" {
    description = "The project in which the resource belongs. If it is not provided, the provider project is used."
    type        = "string"
    default     = ""
}

variable "service_account" {
    description = "Service Account to use with cluster"
    type        = "string"
    default     = ""
}

variable "description" {
    description = "Cluster description"
    type        = "string"
    default     = "Provisioned by Terraform"
}

variable "labels" {
    description = "Cluster Labels"
    type        = "map"
    default     = {}
}

variable "network" {
    description = "Map of network settings"
    type        = "map"
    default     = {}
}

variable "master_config" {
    description = "Common Master Node Configs"
    type        = "map"
    default     = {}
}

variable "addons_config" {
    description = "Addon config settings"
    type        = "map"
    default     = {}
}

variable "node_pools" {
    description = "GKE Node Pool configuration"
    type        = "list"
    default     = []
}

variable "node_pool_labels" {
    description = "Map of labels for Node Pool. This has to be defined (even if empty) for each nodepool set"
    type        = "map"
    default     = {
        default = {}
    }
}

variable "node_pool_tags" {
    description = "Map of tags for Node Pool. This has to be defined (even if empty) for each nodepool se"
    type        = "map"
    default     = {
        default = []
    }
}