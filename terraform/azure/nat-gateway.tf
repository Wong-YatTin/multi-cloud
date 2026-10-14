resource "azurerm_public_ip" "nat_gateway_ip" {
  name                = "nat-gateway-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "aks_nat_gateway" {
  name                    = "aks-nat-gateway"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "nat_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.aks_nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip.id
}

# 將 NAT Gateway 與 AKS 使用的子網路關聯
resource "azurerm_subnet_nat_gateway_association" "aks_subnet1_nat_association" {
  subnet_id      = azurerm_subnet.private1.id
  nat_gateway_id = azurerm_nat_gateway.aks_nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "aks_subnet2_nat_association" {
  subnet_id      = azurerm_subnet.private2.id
  nat_gateway_id = azurerm_nat_gateway.aks_nat_gateway.id
}

