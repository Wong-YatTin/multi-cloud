module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 10.0"

    project_id   = var.project_id
    network_name = "chat-bot-vpc"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "asia-east2"
            subnet_flow_logs      = "true"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "asia-east2"
            subnet_flow_logs      = "true"
        }
    ]

    secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "subnet-01-secondary-01"
                ip_cidr_range = "192.168.0.0/20"
            },
            {
                range_name    = "subnet-01-secondary-02"
                ip_cidr_range = "192.167.0.0/20"
            },
        ]
    }

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
    ]
}

# resource "google_compute_address" "static_ip" {
#  name         = "static-ip"
#  region       = "us-central1"  // Using same region as subnet
#  project      = var.project_id
#  address_type = "EXTERNAL"
# }