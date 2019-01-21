# Terraform GKE Deployment
Terraform module for configuring GKE clusters and node pools.

Supports following:
- Only Beta Google provider
- Regional Cluster
- Removes Default Node Pool
- Create Custom Node Pools
- Must include secondary ranges

## TODO
Documentation incomplete... needs to be updated.

## Usage

```hcl
module "gke" {
    source  = "github.com/muvaki/terraform-google-gke"

    project = "${var.project-id}"
    name    = "test-cluster"

    network = {
        region                   = "us-central1"
        vpc                      = "${module.vpc.name}"
        subnetwork               = "us-central1"
        cluster_secondary_range  = "gke-pods"
        services_secondary_range = "gke-services"
    }

    # service_account   = "${module.gke-sa.email}"
    service_account   = "${module.gke-sa.email}"
    master_config = {
        min_master_version  = "1.11.6-gke.2"
        maintenance_window  = "11:00"
    }

    addons_config = {
        disable_horizontal_pod_autoscaling  = "false"
        disable_http_load_balancing         = "false"
        disable_kubernetes_dashboard        = "true"
        enable_pod_security_policy          = "false"
        enable_tpu                          = "false"
        enable_network_policy_config        = "false"
    }

    module_dependency = "${module.gke-sa.name}"
    
    labels = {
        type = "gke"
        environment = "qa"
    }

    node_pools = [
        {
            name                      = "standard",
            machine_type              = "n1-standard-4"
            initial_node_per_region   = "1"
            max_node_count_per_region = "3"
        }
    ]

    node_pool_labels = {
        standard = {
            type = "nodepool"
            workload = "standard"
        }
    }

    node_pool_tags = {
        standard = ["standard-gke-np"]
    }
}
```

## Docs:

module reference docs: 
- terraform.io (v0.11.11)
- GCP [GKE](https://cloud.google.com/kubernetes-engine/docs/)

### LICENSE

MIT License
