output "endpoint" {
  value       = "${google_container_cluster.default.endpoint}"
  description = "The IP address of this cluster's Kubernetes master."
}

output "master_version" {
  value       = "${google_container_cluster.default.master_version}"
  description =  "The current version of the master in the cluster. This may be different than the min_master_version set in the config if the master has been updated by GKE."
}