data "azurerm_arc_machine" "server" {
  name                = var.serverName
  resource_group_name = var.resourceGroup.name
}

locals {
  RoleList = [
    "Azure Stack HCI Edge Devices role",
    "Key Vault Secrets User",
  ]
}

resource "azurerm_role_assignment" "MachineRoleAssign" {
  for_each             = toset(local.RoleList)
  scope                = "/subscriptions/${var.subId}/resourceGroups/${var.resourceGroup.name}"
  role_definition_name = each.value
  principal_id         = data.azurerm_arc_machine.server.identity[0].principal_id
}

output "server" {
  value       = data.azurerm_arc_machine.server
  description = "The arc server object"
}