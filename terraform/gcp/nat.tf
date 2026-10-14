resource "google_compute_router" "gke_router" {
  name    = "gke-nat-router"
  network = module.vpc.network_name
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "gke_nat" {
  name                               = "gke-nat-config"
  router                             = google_compute_router.gke_router.name
  region                             = google_compute_router.gke_router.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}