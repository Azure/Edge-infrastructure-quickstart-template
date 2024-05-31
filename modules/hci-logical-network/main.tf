locals {
  subnet0PropertiesFull = {
    addressPrefix      = var.addressPrefix, //compute from starting address and ending address
    ipAllocationMethod = "Static",
    ipPools = [{
      info  = {}
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
  subnet0Properties = { for k, v in local.subnet0PropertiesFull : k => v if v != null }
}

resource "azapi_resource" "logicalNetwork" {
  type      = "Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview"
  parent_id = var.resourceGroupId
  name      = var.logicalNetworkName
  location  = var.location
  lifecycle {
    precondition {
      condition     = length(var.startingAddress) > 0 && length(var.endingAddress) > 0 && length(var.defaultGateway) > 0 && length(var.dnsServers) > 0 && length(var.addressPrefix) > 0
      error_message = "When not using existing logical network, startingAddress, endingAddress, defaultGateway, dnsServers, addressPrefix are required"
    }
    ignore_changes = [
      body.properties.subnets[0].properties.ipPools[0].info,
    ]
  }
  body = {
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      dhcpOptions = {
        dnsServers = flatten(var.dnsServers)
      }
      subnets = [{
        name       = "default"
        properties = local.subnet0Properties
      }]
      vmSwitchName = var.vmSwitchName
    }
  }
}
