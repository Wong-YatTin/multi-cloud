variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
  default = "x3uClPToTjzBmE6oWRtk99IHA8boVp9_-maQSMp9"
}


variable "cloudflare_domain" {
  description = "Domain name managed by Cloudflare"
  type        = string
  default     = "hkiit-assistant.me"
}

variable "aks_ip" {
  description = "Azure Kubernetes Load Balancer IP"
  type        = string
}

variable "gke_ip" {
  description = "GCP Kubernetes Load Balancer IP"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = "8f67d577982ab317e796204ca30a1480"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
  default     = "61c6d798c325004c4da5e6225a2811b6"
  
}