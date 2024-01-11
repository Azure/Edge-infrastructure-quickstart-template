resource "azapi_resource" "logicalNetwork" {
  type      = "Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview"
  parent_id = var.resourceGroup.id
  name      = var.logicalNetworkName
  location  = var.resourceGroup.location
  body = jsonencode({
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      dhcpOptions = {
        dnsServers = var.dnsServers
      }
      subnets = [{
        name = "default"
        properties = {
          addressPrefix      = var.addressPrefix ,//compute from starting address and ending address
          ipAllocationMethod = "Static",
          ipPools = [{
            start = var.startingAddress
            end   = var.endingAddress
          }]
          vlan = 201
          routeTable = {
            properties = {
              routes = [
                {
                  name = "default"
                  properties = {
                    addressPrefix    = "0.0.0.0/0",
                    nextHopIpAddress = var.defaultGateway
                  }
                }
              ]
            }
          }
        }
      }]
      vmSwitchName = "ConvergedSwitch(managementcompute)" // This is hardcoded for all cloud deployment hci cluster
    }
  })
  schema_validation_enabled = false
  ignore_casing             = false
  ignore_missing_property   = false
}
