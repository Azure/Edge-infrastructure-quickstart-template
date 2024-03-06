data "azapi_resource" "logicalNetwork" {
  type      = "Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview"
  parent_id = var.resourceGroup.id
  name      = var.logicalNetworkName
  count     = var.usingExistingLogicalNetwork ? 1 : 0
}

resource "azapi_resource" "logicalNetwork" {
  type      = "Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview"
  parent_id = var.resourceGroup.id
  name      = var.logicalNetworkName
  count     = var.usingExistingLogicalNetwork ? 0 : 1
  location  = var.resourceGroup.location
  lifecycle {
    precondition {
      condition = length(var.startingAddress)>0 && length(var.endingAddress)>0 && length(var.defaultGateway)>0 && length(var.dnsServers)>0 && length(var.addressPrefix)>0
      error_message = "When not using existing logical network, startingAddress, endingAddress, defaultGateway, dnsServers, addressPrefix are required"
    }
  }
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
          addressPrefix      = var.addressPrefix, //compute from starting address and ending address
          ipAllocationMethod = "Static",
          ipPools = [{
            start = var.startingAddress
            end   = var.endingAddress
          }]
          vlan = var.vlanId == null ? null : tonumber(var.vlanId)
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
  timeouts {}
}

locals{
  logicalNetworkId = var.usingExistingLogicalNetwork ? data.azapi_resource.logicalNetwork[0].id : azapi_resource.logicalNetwork[0].id
}