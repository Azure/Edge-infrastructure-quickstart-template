resource "azapi_resource" "winServerImage" {
  type      = "Microsoft.AzureStackHCI/marketplaceGalleryImages@2023-09-01-preview"
  name      = "winServer2022-01"
  parent_id = var.resourceGroupId
  location  = var.location
  timeouts {
    create = "24h"
    update = "24h"
    delete = "60m"
  }
  ignore_body_changes = [
    "properties.version.properties.storageProfile.osDiskImage"
  ]
  body = jsonencode({
    properties = {
      osType           = "Windows"
      hyperVGeneration = "V2"
      identifier = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
      }
      version = {
        name = "20348.2113.231109"
        properties = {
          storageProfile = {
            osDiskImage = {
            }
          }
        }
      }
    }
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
  })
}
