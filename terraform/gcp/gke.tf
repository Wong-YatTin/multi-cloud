module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "36.2.0"
  
  project_id = var.project_id
  name       = "gke-private-cluster"
  region     = var.region
  zones      = ["asia-east2-a", "asia-east2-b", "asia-east2-c"]
  
  network                 = module.vpc.network_name
  subnetwork              = "subnet-01"
  ip_range_pods           = "subnet-01-secondary-01"
  ip_range_services       = "subnet-01-secondary-02"

  enable_private_nodes    = true
  enable_private_endpoint = false  
  
  master_ipv4_cidr_block  = "172.16.0.0/28"
  

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"  
      display_name = "Allowed IPs"
    }
  ]
  
  remove_default_node_pool = true
  initial_node_count       = 1
  
  node_pools = [
    {
      name               = "default-pool"
      machine_type       = "e2-medium"
      node_locations     = "asia-east2-a,asia-east2-b"
      min_count          = 1
      max_count          = 3
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
    }
  ]

  # 啟用標準日誌服務
  logging_service = "logging.googleapis.com/kubernetes"

   monitoring_service = "monitoring.googleapis.com/kubernetes"

   deletion_protection = false  
}

resource "null_resource" "deploy_kubernetes_gcp" {
  depends_on = [
    module.gke,
    google_compute_router_nat.gke_nat  # 修正為正確的資源名稱
  ]
  provisioner "local-exec" {
    command = "bash /workspaces/muti-cloud/kubernetes/gke.bash"
    working_dir = "/workspaces/muti-cloud/terraform"
  }
  triggers = {
    run_id = uuid()
  }
}

# 移除未使用的 log_bucket
# resource "google_logging_log_bucket" "main" {
#   name        = "gke-log-bucket"
#   location    = "global"
#   description = "GKE cluster logs"
#   retention_days = 30
# }