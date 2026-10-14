# 首先啟用 Cloud Resource Manager API
resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy         = false
}

# 接著啟用其他所需的 API
resource "google_project_service" "apis" {
  for_each = toset([
    "aiplatform.googleapis.com",          # Vertex AI (Gemini)
    "secretmanager.googleapis.com",       # 存儲密鑰
    "storage.googleapis.com",             # 文件存儲
    "iam.googleapis.com",                 # IAM 權限管理
    "sql-component.googleapis.com",        # Cloud SQL
    "sqladmin.googleapis.com",            #Cloud SQL Admin API
    "compute.googleapis.com",             # Compute Engine (needed for SQL)
    "container.googleapis.com",           # GKE
    "speech.googleapis.com",              # 語音轉文字
    "texttospeech.googleapis.com",        # 文字轉語音
    "apikeys.googleapis.com",             # API 金鑰
    "logging.googleapis.com",             # Cloud Logging
    "monitoring.googleapis.com"           # Cloud Monitoring
  ])
  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
  

  depends_on = [google_project_service.cloudresourcemanager]
}
