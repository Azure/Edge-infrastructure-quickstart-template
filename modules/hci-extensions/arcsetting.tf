data "azapi_resource" "arcSetting" {
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings@2023-08-01"
  parent_id = var.clusterId
  name      = "default"
}
