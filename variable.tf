# General Configs
variable "module_dependency" {
  type        = string
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
    default     = null
}

variable "service_account" {
    description = "Service Account to use with cluster"
    type        = string
    default     = null
}

variable "description" {
    description = "Cluster description"
    type        = string
    default     = "GKE Cluster - Provisioned by Terraform"
}

variable "labels" {
    description = "Cluster Labels"
    type        = "map"
    default     = {}
}

variable "gke_version" {
    description = "Give GKE Version"
    type        = "string"
}

# container specific

variable "location" {
    description = "The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well."
    type        = string
}

# addon config
variable "horizontal_pod_autoscaling" {
    description = "The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods a replication controller has based on the resource usage of the existing pods. It ensures that a Heapster pod is running in the cluster, which is also used by the Cloud Monitoring service."
    type        = bool
    default     = false
}

variable "http_load_balancing" {
    description = "The status of the HTTP (L7) load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster. "
    type        = bool
    default     = false
}

variable "kubernetes_dashboard" {
    description = "The status of the Kubernetes Dashboard add-on, which controls whether the Kubernetes Dashboard is enabled for this cluster."
    type        = bool
    default     = true
}

variable "istio" {
    description = "Enabling GKE supported ISTIO"
    type        = object({
        disabled = bool
        auth     = string
    })
    default = null
}

variable "cloudrun" {
    description = "Enabling cloudrun workloads on GKE Cluster. It requires istio config to be enabled"
    type        = bool
    default     = true
}

# other configs
variable "cluster_ipv4_cidr" {
    description = "The IP address range of the kubernetes pods in this cluster. Default is an automatically assigned CIDR."
    type        = string
    default     = null
}

variable "cluster_autoscaling" {
    description = "Per-cluster configuration of Node Auto-Provisioning with Cluster Autoscaler to automatically adjust the size of the cluster and create/delete node pools based on the current needs of the cluster's workload. Description at https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-provisioning"
    type        = list(object({
        type = string
        min  = number
        max  = number
    }))
    default = null
}

variable "database_encryption" {
    description = "Uses KMS Key to encrypt ETCD"
    type        = object({
        state    = string
        key_name = number
    })
    default = null
}

variable "default_max_pods_per_node" {
    description = "The default maximum number of pods per node in this cluster. Note that this does not work on node pools which are route-based - that is, node pools belonging to clusters that do not have IP Aliasing enabled. See the official documentation for more information."
    type        = number
    default     = null
}

variable "enable_binary_authorization" {
    description = "Enable Binary Authorization for this cluster. If enabled, all container images will be validated by Google Binary Authorization."
    type        = bool
    default     = false
}

variable "enable_tpu" {
    description = "Whether to enable Cloud TPU resources in this cluster."
    type        = bool
    default     = false
}

variable "ip_allocation_policy" {
    description = "Passing values to this block enables VPC Native and IP Alias features"
    type        = object({
        cluster_secondary_range_name  = string
        services_secondary_range_name = string
    })
    default = null
}

variable "logging_service" {
    description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes, and none"
    type        = string
    default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
    description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes, and none"
    type        = string
    default     = "monitoring.googleapis.com/kubernetes"
}

variable "master_authorized_networks" {
    description = "The desired configuration options for master authorized networks. Takes cidr and display name and maps it to authorized access to master list"
    type        = list(object({
        cidr_block   = string
        display_name = string
    }))
    default = null
}

variable "vpc" {
    description = "The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network."
    type        = string
}

variable "subnet" {
    description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
    type        = string
}

variable "network_policy" {
  description = " Configuration options for the NetworkPolicy feature."
  type        = object({
      provider = string
      enabled  = bool
  })
  default = null
}

variable "pod_security_policy" {
    description = "Enable the PodSecurityPolicy controller for this cluster. If enabled, pods must be valid under a PodSecurityPolicy to be created."
    type        = bool
    default     = false
}

variable "security_group" {
    description = "The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format gke-security-groups@yourdomain.com."
    type        = string
    default     = null
}

variable "private_cluster_config" {
    description = "A set of options for creating a private cluster. Structure is documented below."
    type        = object({
        enable_private_endpoint = bool
        enable_private_nodes    = bool
        master_ipv4_cidr_block  = string
    })
    default = null
}

variable "bq_usage" {
    description = "Enable usage charts to bigquery"
    type        = object({
        egress_metering = bool
        dataset_id      = string
    })
    default = null
}

variable "vertical_pod_autoscaling" {
    description = "Enable veritcal pod autoscaling support"
    type        = bool
    default     = true
}

variable "enable_workload_identity" {
    description = "enable workload identity. https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity"
    type        = bool
    default     = false
}

variable "enable_intranode_visibility" {
    description = "Whether Intra-node visibility is enabled for this cluster. This makes same node pod to pod traffic visible for VPC network."
    type        = bool
    default     = false
}

variable "maintenance_window" {
    description = "Time window specified for daily maintenance operations. Specify start_time in RFC3339 format HH:MM, where HH : [00-23] and MM : [00-59] GMT."
    type        = string
    default     = "03:00"
}

# Node Pools
variable "node_pools" {
    description = "the information for node pool"
    type        = list(object({
        name              = string
        machine_type      = string
        labels            = map(string)
        service_account   = string
        tags              = list(string)
        max_pods_per_node = number
        min_node_per_zone = number
        max_node_per_zone = number
    }))
}