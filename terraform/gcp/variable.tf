variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "vtc-project-427316"
}

variable "region" {
  description = "Default Region"
  type        = string
  default     = "asia-east2"
}



variable "vpc_id" {
  description = "VPC network ID"
  type        = string
  default     = "default"
}
