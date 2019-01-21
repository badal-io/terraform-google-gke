data "google_client_config" "default" {}

locals {
    # network related settings
    region      = "${lookup(var.network, "region", "us-east4")}"
    network     = "projects/${var.project}/global/networks/${lookup(var.network, "vpc")}"
    subnetwork  = "projects/${var.project}/regions/${local.region}/subnetworks/${lookup(var.network, "subnetwork")}"
    tags        = ["${concat(split(",",lookup(var.network, "tags", "")), list(format("%s-gke", var.name)))}"]
    cluster_secondary_range_name = "${lookup(var.network, "cluster_secondary_range")}"
    services_secondary_range_name = "${lookup(var.network, "services_secondary_range")}"
    # Master common settings
    min_master_version          = "${lookup(var.master_config, "min_master_version")}"
    maintenance_window          = "${lookup(var.master_config, "maintenance_window_start_time", "03:00")}"

    # Addons to enable/disable
    horizontal_pod_autoscaling  = "${lookup(var.addons_config, "disable_horizontal_pod_autoscaling", "false")}"
    http_load_balancing         = "${lookup(var.addons_config, "disable_http_load_balancing", "false")}"
    kubernetes_dashboard        = "${lookup(var.addons_config, "disable_kubernetes_dashboard", "true")}"
    network_policy              = "${lookup(var.addons_config, "enable_network_policy_config", "true")}"
    tpu_enabled                 = "${lookup(var.addons_config, "enable_tpu", "false")}"
    # cluster_autoscaling         = "${lookup(var.addons_config, "enable_cluster_autoscaling", "true")}"
    pod_security_policy         = "${lookup(var.addons_config, "enable_pod_security_policy", "false")}"

}