data "google_client_config" "default" {}

locals {
    project-id = "${var.project == null ? var.project : data.google_client_config.default.project}"
    workload_identity_default = "${local.project-id}.svc.id.goog"
}

/*
*       MASTER GKE
*
*     - Works only with Regions
*     - Removes default Node Pool
*/

data "google_container_engine_versions" "default" {
    project        = "${local.project-id}"
    location       = "${var.location}"
    version_prefix = "${var.gke_version}"
}

resource "google_container_cluster" "default" {
    project     = "${local.project-id}"
    
    name        = "${var.name}"
    description = "${var.description}"
    location    = "${var.location}"

    resource_labels = "${var.labels}"

    # all node pools should be managed independently
    remove_default_node_pool = "true"
    # define network and subnetwork
    network             = "${var.vpc}"
    subnetwork          = "${var.subnet}"

    # Enforcing new dashboard
    logging_service     = "${var.logging_service}"
    monitoring_service  = "${var.monitoring_service}"

    addons_config {
        horizontal_pod_autoscaling {
            disabled = "${var.horizontal_pod_autoscaling}"
        }
        http_load_balancing {
            disabled = "${var.http_load_balancing}"
        }
        kubernetes_dashboard {
            disabled = "${var.kubernetes_dashboard}"
        }
        network_policy_config {
            disabled = "${var.network_policy == null ? true : false}"
        }

        dynamic "istio_config" {
            for_each = var.istio == null ? [] : list(var.istio)

            content {
                disabled = istio_config.value.disabled
                auth     = istio_config.value.auth
            }
        }

        cloudrun_config {
            disabled = "${var.istio != null ? var.istio.disabled == false ? var.cloudrun : true : true}"
        }
    }

    dynamic "network_policy" {
        for_each = var.network_policy == null ? [] : list(var.network_policy)

        content {
            provider = network_policy.value.provider
            enabled  = network_policy.value.enabled
        }
    }

    cluster_ipv4_cidr = "${var.cluster_ipv4_cidr }"
    
    dynamic "cluster_autoscaling" {
        for_each = var.cluster_autoscaling == null ? [] : [{
            enabled = true
            resources = var.cluster_autoscaling
        }]

        content {
            enabled = cluster_autoscaling.value.enabled
            dynamic "resource_limits" {
                for_each = cluster_autoscaling.value.resources

                content {
                    resource_type = resource_limits.value.type
                    minimum       = resource_limits.value.min
                    maximum       = resource_limits.value.max
                }
            }
        }
    }

    dynamic "database_encryption" {
        for_each = var.database_encryption == null ? [] : list(var.database_encryption)

        content {
            state    = database_encryption.value.state
            key_name = database_encryption.value.key_name
        }
    }

    default_max_pods_per_node   = "${var.default_max_pods_per_node}"
    enable_binary_authorization = "${var.enable_binary_authorization}"
    enable_tpu                  = "${var.enable_tpu}"

    pod_security_policy_config {
        enabled = "${var.pod_security_policy}"
    }

    # currently only support pre-created secondary ranges
    dynamic "ip_allocation_policy" {
        for_each = var.ip_allocation_policy == null ? [] : list(var.ip_allocation_policy)

        content {
            cluster_secondary_range_name    = ip_allocation_policy.value.cluster_secondary_range_name
            services_secondary_range_name   = ip_allocation_policy.value.services_secondary_range_name
        }
    }

    # Hard Coding this block to disable basic auth / cert creation
    master_auth {
        password = ""
        username = ""
        client_certificate_config {
            issue_client_certificate = false
        }
    }

    dynamic "master_authorized_networks_config" {
        for_each = var.master_authorized_networks == null ? [] : var.master_authorized_networks

        content {
            cidr_blocks {
                cidr_block   = master_authorized_networks_config.value.cidr_block
                display_name = master_authorized_networks_config.value.display_name
            }
        }
    }

    min_master_version = "${data.google_container_engine_versions.default.latest_master_version}"

    maintenance_policy {
        daily_maintenance_window {
            start_time = "${var.maintenance_window}"
        }
    }

    dynamic "authenticator_groups_config" {
        for_each = var.security_group == null ? [] : list({
            group = var.security_group
        })

        content {
            security_group = authenticator_groups_config.value.group
        }
    }

    dynamic "private_cluster_config" {
        for_each = var.private_cluster_config == null ? [] : list(var.private_cluster_config)

        content {
            enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
            enable_private_nodes    = private_cluster_config.value.enable_private_nodes
            master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
        }
    }

    dynamic "resource_usage_export_config" {
        for_each = var.bq_usage == null ? [] : list(var.bq_usage)

        content {
            enable_network_egress_metering = resource_usage_export_config.value.egress_metering
            bigquery_destination {
                dataset_id = resource_usage_export_config.value.dataset_id
            }
        }
    }

    vertical_pod_autoscaling {
        enabled = "${var.vertical_pod_autoscaling}"
    }

    enable_intranode_visibility = "${var.enable_intranode_visibility}"

    # workload_identity_config = "${var.enable_workload_identity ? local.workload_identity_default : null}"

    # Since we remove default-pool we need to ignore any lifecycle changes to it
    lifecycle {
        ignore_changes = ["node_pool"]
    }

    node_pool {
        name = "default-pool"
    }
}

/*
*       GKE NODE POOLS
*/
resource "google_container_node_pool" "pool" {
  count       = "${var.node_pools == null ? 0 : length(var.node_pools)}"

  location    = "${var.location}"
  project     = "${local.project-id}"
  cluster     = "${google_container_cluster.default.name}"

  name        = "${var.node_pools[count.index].name}"

  initial_node_count = "${var.node_pools[count.index].min_node_per_zone}"
  max_pods_per_node = "${var.node_pools[count.index].max_pods_per_node}"

  node_config {
    machine_type    = "${var.node_pools[count.index].machine_type}"
    labels          = "${var.node_pools[count.index].labels}"
    service_account = "${var.node_pools[count.index].service_account}"
    tags            = "${var.node_pools[count.index].tags}"
  }

  autoscaling {
    min_node_count = "${var.node_pools[count.index].min_node_per_zone}"
    max_node_count = "${var.node_pools[count.index].max_node_per_zone}" 
  }

    # hardcoding gke goodies for now
    management {
        auto_repair   = true
        auto_upgrade  = true
    }
}