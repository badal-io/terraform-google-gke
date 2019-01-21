/*
*       GKE NODE POOLS
*/
resource "google_container_node_pool" "pool" {
  count       = "${length(var.node_pools) > 0 ? length(var.node_pools) : 0}"

  name        = "${lookup(var.node_pools[count.index], "name")}"
  region      = "${local.region}"
  project     = "${length(var.project) > 0 ? var.project : data.google_client_config.default.project}"
  cluster     = "${google_container_cluster.default.name}"

  initial_node_count = "${lookup(var.node_pools[count.index], "initial_node_per_region", "1")}"

  node_config {
    disk_size_gb    = "${lookup(var.node_pools[count.index], "disk_size_gb", "100")}"
    disk_type       = "${lookup(var.node_pools[count.index], "disk_type", "pd-standard")}"
    machine_type    = "${lookup(var.node_pools[count.index], "machine_type", "n1-standard-1")}"
    labels          = "${var.node_pool_labels[lookup(var.node_pools[count.index], "name")]}"
    service_account = "${var.service_account}"
    tags            = "${var.node_pool_tags[lookup(var.node_pools[count.index], "name")]}"
    # This can be cleaned up but currently its enabled for all scopes because the access is controlled at SA level
    oauth_scopes    = ["cloud-platform"]
  }

  autoscaling {
    min_node_count = "${lookup(var.node_pools[count.index], "min_node_count_per_region", "1")}"
    max_node_count = "${lookup(var.node_pools[count.index], "max_node_count_per_region", "1")}" 
  }

  management {
    auto_repair   = "${lookup(var.node_pools[count.index], "auto_repair", "true")}"
    auto_upgrade  = "${lookup(var.node_pools[count.index], "auto_upgrade", "true")}"
  }
}