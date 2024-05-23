resource "azapi_resource" "cluster" {
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  parent_id = var.resourceGroup.id
  name      = var.clusterName
  depends_on = [ azurerm_role_assignment.ServicePrincipalRoleAssign ]

  body = {
    properties = {}
  }

  lifecycle {
    ignore_changes = [
      body.properties,
      identity[0]
    ]
  }
  identity {
    type = "SystemAssigned"
  }
  
  location = var.resourceGroup.location
}

# Generate random integer suffix for storage account and key vault
resource "random_integer" "random_suffix" {
  min = 10
  max = 99
}
