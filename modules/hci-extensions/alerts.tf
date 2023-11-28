resource "azapi_resource" "alerts" {
  count     = var.enableAlerts && var.enableInsights ? 1 : 0
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
  parent_id = data.azapi_resource.arcSetting.id
  name      = "AzureEdgeAlerts"
  body = jsonencode({
    properties = {
      extensionParameters = {
        enableAutomaticUpgrade = true
        autoUpgradeMinorVersion = false
        publisher              = "Microsoft.AzureStack.HCI.Alerts"
        type                   = "AlertsForWindowsHCI"
        settings = {}
      }
    }
  })
}
