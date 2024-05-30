resource "azapi_resource" "hybrid_compute_machine" {
  type      = "Microsoft.HybridCompute/machines@2023-10-03-preview"
  name      = var.vmName
  location  = var.location
  parent_id = var.resourceGroupId

  identity {
    type = "SystemAssigned"
  }

  body = {
    kind = "HCI",
  }
}

resource "azapi_resource" "virtual_machine" {
  type      = "Microsoft.AzureStackHCI/virtualMachineInstances@2023-09-01-preview"
  name      = "default" # value must be 'default' per 2023-09-01-preview
  parent_id = azapi_resource.hybrid_compute_machine.id

  body = {
    extendedLocation = {
      type = "CustomLocation"
      name = var.customLocationId
    }
    properties = {
      hardwareProfile = {
        vmSize     = "Custom"
        processors = var.vCPUCount
        memoryMB   = var.memoryMB
        dynamicMemoryConfig = var.dynamicMemory ? null : {
          maximumMemoryMB    = var.dynamicMemoryMax
          minimumMemoryMB    = var.dynamicMemoryMin
          targetMemoryBuffer = var.dynamicMemoryBuffer
        }
      }
      osProfile = {
        adminUsername = var.adminUsername
        adminPassword = var.adminPassword
        computerName  = var.vmName
        windowsConfiguration = {
          provisionVMAgent       = true
          provisionVMConfigAgent = true
        }
      }
      storageProfile = {
        vmConfigStoragePathId = var.userStorageId == "" ? null : var.userStorageId
        imageReference = {
          id = var.imageId
        }
        dataDisks = [for i in range(length(var.dataDiskParams)) : {
          id = azapi_resource.data_disks[i].id
        }]
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.nic.id
          }
        ]
      }
    }
  }

  timeouts {
    create = "2h"
  }
}
