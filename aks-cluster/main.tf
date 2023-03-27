// Making use of existing RG to implement "data" block functionality

data "azurerm_resource_group" "mwiki-rg" {
    name = "mwiki-rg"
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr-name
  resource_group_name = data.azurerm_resource_group.mwiki-rg.name
  location            = data.azurerm_resource_group.mwiki-rg.location
  sku                 = "Standard"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks-name
  location            = data.azurerm_resource_group.mwiki-rg.location
  resource_group_name = data.azurerm_resource_group.mwiki-rg.name
  dns_prefix          = "mwikiaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
 
 depends_on = [
   azurerm_container_registry.acr
 ]
 
}

// Giving AKS role to pull the images from ACR 
resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks
  ]
}