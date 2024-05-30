resource "azapi_resource" "nic" {
  type      = "Microsoft.AzureStackHCI/networkInterfaces@2023-09-01-preview"
  name      = "${var.vmName}-nic"
  location  = var.location
  parent_id = var.resourceGroupId

  body = {
    extendedLocation = {
      type = "CustomLocation"
      name = var.customLocationId
    }

    properties = {
      ipConfigurations = [{
        name = null
        properties = {
          subnet = {
            id = var.logicalNetworkId
          }
          privateIPAddress = var.privateIPAddress == "" ? null : var.privateIPAddress
        }
      }]
    }
  }
}
