data "azapi_resource" "arcbridge" {
  depends_on = [azapi_update_resource.deploymentsetting]
  type       = "Microsoft.ResourceConnector/appliances@2022-10-27"
  name       = "${var.clusterName}-arcbridge"
  parent_id  = var.resourceGroup.id
}

data "azapi_resource" "customlocation" {
  depends_on = [azapi_update_resource.deploymentsetting]
  type       = "Microsoft.ExtendedLocation/customLocations@2021-08-15"
  name       = var.customLocationName
  parent_id  = var.resourceGroup.id
}

data "azapi_resource_list" "userStorages" {
  depends_on             = [azapi_update_resource.deploymentsetting]
  type                   = "Microsoft.AzureStackHCI/storagecontainers@2022-12-15-preview"
  parent_id              = var.resourceGroup.id
  response_export_values = ["*"]
}

data "azapi_resource" "arcSettings" {
  depends_on = [ azapi_update_resource.deploymentsetting ]
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings@2023-08-01"
  parent_id = azapi_resource.cluster.id
  name      = "default"
}

locals {
  decodedUserStorages = jsondecode(data.azapi_resource_list.userStorages.output).value
  ownedUserStorages   = [for storage in local.decodedUserStorages : storage if lower(storage.extendedLocation.name) == lower(data.azapi_resource.customlocation.id)]
}

output "cluster" {
  value       = azapi_resource.cluster
  description = "HCI Cluster instance"
}

output "keyvault" {
  value       = azurerm_key_vault.DeploymentKeyVault
  description = "Keyvault instance that stores deployment secrets."
}

output "arcbridge" {
  value       = data.azapi_resource.arcbridge
  description = "Arc resource bridge instance after HCI connected."
}

output "customlocation" {
  value       = data.azapi_resource.customlocation
  description = "Custom location instance after HCI connected."
}

output "userStorages" {
  value       = local.ownedUserStorages
  description = "User storage instances after HCI connected."
}

output "arcSettings" {
  value       = data.azapi_resource.arcSettings
  description = "Arc settings instance after HCI connected."
}

output "vSwitchName" {
  value       = local.converged ? "ConvergedSwitch(managementcomputestorage)" : "ConvergedSwitch(managementcompute)"
  description = "The name of the virtual switch that is used by the network."
}
