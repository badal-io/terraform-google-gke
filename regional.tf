/*
*       MASTER GKE
*
*     - Works only with Regions
*     - Removes default Node Pool
*/
resource "google_container_cluster" "default" {
    provider = "google-beta"

    name        = "${var.name}"
    region      = "${local.region}"
    project     = "${length(var.project) > 0 ? var.project : data.google_client_config.default.project}"
    description = "${var.description}"

    # set min version due to version upgrades
    min_master_version        = "${local.min_master_version}"
    resource_labels           = "${var.labels}"

    # all node pools should be managed independently
    remove_default_node_pool  = "true"
    # define network and subnetwork
    network             = "${local.network}"
    subnetwork          = "${local.subnetwork}"

    logging_service     = "logging.googleapis.com/kubernetes"
    monitoring_service  = "monitoring.googleapis.com/kubernetes"

    enable_tpu          = "${local.tpu_enabled}"

    addons_config {
        horizontal_pod_autoscaling {
            disabled = "${local.horizontal_pod_autoscaling}"
        }
        http_load_balancing {
            disabled = "${local.http_load_balancing}"
        }
        kubernetes_dashboard {
            disabled = "${local.kubernetes_dashboard}"
        }
        network_policy_config {
            disabled = "${local.network_policy == "true" ? "false" : local.network_policy}"
        }
    }

    network_policy {
        provider = "PROVIDER_UNSPECIFIED"
        enabled = "${local.network_policy}"
    }
    
    # not available for regional as of yet

    # cluster_autoscaling {
    #     enabled = "${local.cluster_autoscaling}"
    # }

    pod_security_policy_config {
        enabled = "${local.pod_security_policy}"
    }

    ip_allocation_policy {
        cluster_secondary_range_name    = "${local.cluster_secondary_range_name}"
        services_secondary_range_name   = "${local.services_secondary_range_name}"
    }

    maintenance_policy {
        daily_maintenance_window {
            start_time = "${local.maintenance_window}"
        }
    }

    # Since we remove default-pool we need to ignore any lifecycle changes to it
    lifecycle {
        ignore_changes = ["node_pool"]
    }

    node_pool {
        name = "default-pool"
    }
}