terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"  # 修正拼寫錯誤
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}