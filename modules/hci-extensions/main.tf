module "insights" {
  count         = var.enableInsights ? 1 : 0
  source        = "./insights"
  siteId        = var.siteId
  resourceGroup = var.resourceGroup
  clusterId     = var.clusterId
  serverNames   = var.serverNames
  arcSettingId  = data.azapi_resource.arcSetting
}
