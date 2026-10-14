resource "cloudflare_record" "aks" {
  zone_id = var.cloudflare_zone_id
  name    = "api-azure"
  content = var.aks_ip
  type    = "A"
  ttl     = 1
  proxied = true  # 啟用 Cloudflare 代理以獲得 SSL 保護
}

# GKE 服務的 DNS 記錄
resource "cloudflare_record" "gke" {
  zone_id = var.cloudflare_zone_id
  name    = "api"
  content = var.gke_ip
  type    = "A"
  ttl     = 1
  proxied = true  # 啟用 Cloudflare 代理
}

# 修正 TCP 監控配置
resource "cloudflare_load_balancer_monitor" "tcp_monitor" {
  account_id     = var.cloudflare_account_id
  type        = "tcp"  # 使用 TCP 檢查替代 HTTP 檢查
  port        = 443    # 檢查 HTTPS 端口
  interval    = 30
  timeout     = 5
  retries     = 2
  description = "TCP 連接監控"
}

# 修正負載平衡池配置，添加監控關聯
resource "cloudflare_load_balancer_pool" "aks_pool" {
  account_id = var.cloudflare_account_id
  name = "aks-pool"
  
  origins {
    name    = "aks-origin"
    address = var.aks_ip
    weight  = 1
    enabled = true
  }
  
  monitor = cloudflare_load_balancer_monitor.tcp_monitor.id
  check_regions = ["APAC", "ENAM", "WNAM"]  # 增加檢查區域
}

resource "cloudflare_load_balancer_pool" "gke_pool" {
  account_id = var.cloudflare_account_id
  name = "gke-pool"
  
  origins {
    name    = "gke-origin"
    address = var.gke_ip
    weight  = 1
    enabled = true
  }
  
  monitor = cloudflare_load_balancer_monitor.tcp_monitor.id
  check_regions = ["APAC", "ENAM", "WNAM"]  # 保持相同的檢查區域
}

# 修正負載平衡器配置
resource "cloudflare_load_balancer" "app_lb" {
  zone_id = var.cloudflare_zone_id
  name    = "app-lb"
  default_pool_ids = [
    cloudflare_load_balancer_pool.aks_pool.id,
    cloudflare_load_balancer_pool.gke_pool.id
  ]
  fallback_pool_id = cloudflare_load_balancer_pool.aks_pool.id
  
  # 修改為負載導向策略
  steering_policy = "dynamic_latency"  # 基於延遲的動態負載均衡
  
  # 啟用 Cloudflare 代理
  proxied = true
  
  # 移除地理分區路由配置
  # 當使用 dynamic_latency 時，Cloudflare 會自動根據延遲選擇最佳的後端
}

# 修正 CNAME 記錄配置
resource "cloudflare_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = "app" 
  content = cloudflare_load_balancer.app_lb.id
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# 新增一個全域 CNAME 以方便使用
resource "cloudflare_record" "api_global" {
  zone_id = var.cloudflare_zone_id
  name    = "api-global" 
  content = "app.hkiit-assistant.me"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}