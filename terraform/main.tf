variable "aks_ip" {
  type    = string
  default = ""
}

variable "gke_ip" {
  type    = string
  default = ""
}

module "azure" {
    source = "./azure"
}

module "gcp" {
    source = "./gcp"
}

# 確保 variable.tfvars 被複製到正確位置

module "cf_dns" {
    source = "./cloudflare"
    aks_ip = var.aks_ip
    gke_ip = var.gke_ip
}