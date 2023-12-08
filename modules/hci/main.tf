resource "azurerm_resource_group" "rg" {
  name     = "${var.siteId}-rg"
  location = var.location
  tags     = {}
}

resource "azapi_resource" "cluster1" {
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  parent_id = azurerm_resource_group.rg.id
  name      = "${var.siteId}-cl" // this should be the same with the one when you create AD

  body = jsonencode({
    identity = {
      type = "SystemAssigned"
    }
    location   = azurerm_resource_group.rg.location
    properties = {}
  })

  schema_validation_enabled = false
  ignore_missing_property   = false
}
