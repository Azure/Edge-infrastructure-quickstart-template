data "azapi_resource" "arcbridge" {
  depends_on = [azapi_update_resource.deploymentsetting]
  type       = "Microsoft.ResourceConnector/appliances@2022-10-27"
  name       = "${var.siteId}-cl-arcbridge"
  parent_id  = azurerm_resource_group.rg.id
}

data "azapi_resource" "customlocation" {
  depends_on = [azapi_update_resource.deploymentsetting]
  type       = "Microsoft.ExtendedLocation/customLocations@2021-08-15"
  name       = "${var.siteId}-customlocation"
  parent_id  = azurerm_resource_group.rg.id
}

data "azapi_resource" "userStorage1" {
  depends_on = [azapi_update_resource.deploymentsetting]
  type = "Microsoft.AzureStackHCI/storagecontainers@2022-12-15-preview"
  name       = "UserStorage1"
  parent_id  = azurerm_resource_group.rg.id
}

data "azapi_resource" "userStorage2" {
  depends_on = [azapi_update_resource.deploymentsetting]
  type = "Microsoft.AzureStackHCI/storagecontainers@2022-12-15-preview"
  name       = "UserStorage2"
  parent_id  = azurerm_resource_group.rg.id
}

output "resourceGroup" {
  value       = azurerm_resource_group.rg
  description = "Resource group"
}

output "cluster" {
  value       = azapi_resource.cluster1
  description = "HCI Cluster instance"
}

output "hosts" {
  value = module.servers
}

output "arcbridge" {
  value       = data.azapi_resource.arcbridge
  description = "Arc resource bridge instance after HCI connected."
}

output "customlocation" {
  value       = data.azapi_resource.customlocation
  description = "Custom location instance after HCI connected."
}

output "userStorage1" {
  value       = data.azapi_resource.userStorage1
  description = "User storage 1 instance after HCI connected."
}

output "userStorage2" {
  value       = data.azapi_resource.userStorage2
  description = "User storage 2 instance after HCI connected."
}
