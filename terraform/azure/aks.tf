resource "azurerm_kubernetes_cluster" "main" {
  name                = "AKSCluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "akscluster"
  kubernetes_version  = "1.31"
  
  default_node_pool {
    name                = "default"
    vm_size             = "Standard_D2_v2"
    node_count          = 1
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    vnet_subnet_id      = azurerm_subnet.private1.id
    zones               = ["1", "2"]
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
  }
  
  private_cluster_enabled = true
  
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  }
}


# 第二個節點池
resource "azurerm_kubernetes_cluster_node_pool" "secondary" {
  name                  = "pool2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D2_v2"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 2
  vnet_subnet_id        = azurerm_subnet.private2.id
  zones                 = ["1", "2"]
}

# Log Analytics 整合
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-analytics"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "example" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.example.id
  workspace_name        = azurerm_log_analytics_workspace.example.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "null_resource" "deploy_kubernetes" {
  depends_on = [
    azurerm_kubernetes_cluster.main,
    azurerm_kubernetes_cluster_node_pool.secondary,
    azurerm_log_analytics_workspace.example,
    azurerm_log_analytics_solution.example,
    azurerm_subnet_nat_gateway_association.aks_subnet1_nat_association,
    azurerm_subnet_nat_gateway_association.aks_subnet2_nat_association
  ]
  provisioner "local-exec" {
    command = "bash /workspaces/muti-cloud/kubernetes/aks.bash"
    working_dir = "/workspaces/muti-cloud/terraform"  # 確保在正確目錄執行
  }
  triggers = {
     run_id = uuid()  # 確保每次 apply 都執行
  }
}
