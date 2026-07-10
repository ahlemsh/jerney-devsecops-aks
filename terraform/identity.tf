resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.aks_cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    project     = var.project_name
    environment = "lab"
    owner       = "ahlem"
  }
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}