resource "azapi_resource" "cluster" {
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  parent_id = var.resourceGroup.id
  name      = "${var.siteId}-cl" // this should be the same with the one when you create AD

  body = jsonencode({
    identity = {
      type = "SystemAssigned"
    }
    location   = var.resourceGroup.location
    properties = {}
  })

  schema_validation_enabled = true
  ignore_missing_property   = true
  ignore_body_changes = [
    "properties"
  ]
  timeouts {}
}
