resource "azapi_resource" "data_disks" {
  count     = length(var.dataDiskParams)
  type      = "Microsoft.AzureStackHCI/virtualHardDisks@2023-09-01-preview"
  name      = "${var.vmName}dataDisk${format("%02d", count.index + 1)}"
  location  = var.location
  parent_id = var.resourceGroupId

  body = {
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      diskSizeGB = var.dataDiskParams[count.index].diskSizeGB
      dynamic    = var.dataDiskParams[count.index].dynamic
      // containerId: uncomment if you want to target a specific CSV/storage path in your HCI cluster
    }
  }
}
