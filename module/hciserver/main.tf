data "azurerm_resources" "arcnodes" {
  name                = var.serverName
  resource_group_name = var.resourceGroup
  type                = "Microsoft.HybridCompute/machines"
}

resource "terraform_data" "provisioner" {
  //count = length(data.azurerm_resources.arcnodes.resources) == 0 ? 1 : 0

  //triggers_replace = file("${path.module}/connect.ps1")
  provisioner "local-exec" {
    command = "powershell.exe -ExecutionPolicy Bypass -File ${path.module}\\connect.ps1 -userName .\\${var.localAdminUser} -password ${var.localAdminPassword} -ip ${var.serverIP} -subId ${var.subId} -resourceGroupName ${var.resourceGroup} -region ${var.location} -tenant ${var.tenant} -servicePricipalId ${var.servicePricipalId} -servicePricipalSecret ${var.servicePricipalSecret}"
  }

  provisioner "local-exec" {
    command = "echo connected ${var.serverName}"
  }
}

data "azurerm_arc_machine" "server" {
  depends_on          = [terraform_data.provisioner]
  name                = var.serverName
  resource_group_name = var.resourceGroup
}

locals {
  RoleList = [
    "Azure Stack HCI Edge Devices role",
    "Key Vault Secrets User",
    //"Azure Stack HCI Device Management Role"
  ]
}

resource "azurerm_role_assignment" "MachineRoleAssign-1" {
  for_each             = toset(local.RoleList)
  scope                = "/subscriptions/${var.subId}/resourceGroups/${var.resourceGroup}"
  role_definition_name = each.value
  principal_id         = data.azurerm_arc_machine.server.identity[0].principal_id
}

output "server" {
  value       = data.azurerm_arc_machine.server
  description = "The arc server object"
}
