resource "azapi_update_resource" "deploymentsetting" {
  count      = var.isExported ? 0 : 1
  type       = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2023-08-01-preview"
  name       = "default"
  parent_id  = azapi_resource.cluster.id
  depends_on = [azapi_resource.validatedeploymentsetting, azapi_resource.validatedeploymentsetting_seperate]
  timeouts {
    create = "24h"
    delete = "60m"
  }
  body = {
    properties = {
      deploymentMode = "Deploy"
    }
  }
}
