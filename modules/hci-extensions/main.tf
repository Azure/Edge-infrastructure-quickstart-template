module "insights" {
  count                      = var.enableInsights ? 1 : 0
  source                     = "./insights"
  siteId                     = var.siteId
  resourceGroup              = var.resourceGroup
  serverNames                = var.serverNames
  arcSettingId               = var.arcSettingsId
  workspaceName              = var.workspaceName
  dataCollectionRuleName     = var.dataCollectionRuleName
  dataCollectionEndpointName = var.dataCollectionEndpointName
}

resource "azapi_resource" "alerts" {
  count     = var.enableAlerts && var.enableInsights ? 1 : 0
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
  parent_id = var.arcSettingsId
  name      = "AzureEdgeAlerts"
  body = {
    properties = {
      extensionParameters = {
        enableAutomaticUpgrade  = true
        autoUpgradeMinorVersion = false
        publisher               = "Microsoft.AzureStack.HCI.Alerts"
        type                    = "AlertsForWindowsHCI"
        settings                = {}
      }
    }
  }
}
