data "azurerm_arc_machine" "server" {
  name                = var.serverName
  resource_group_name = var.resourceGroup.name
}

locals {
  Roles = {
    KVSU   = "Key Vault Secrets User",
    ACMRM  = "Azure Connected Machine Resource Manager",
    ASHDMR = "Azure Stack HCI Device Management Role",
    Reader = "Reader"
  }
}

resource "azurerm_role_assignment" "MachineRoleAssign" {
  for_each             = local.Roles
  scope                = "/subscriptions/${var.subscriptionId}/resourceGroups/${var.resourceGroup.name}"
  role_definition_name = each.value
  principal_id         = data.azurerm_arc_machine.server.identity[0].principal_id
}

output "server" {
  value       = data.azurerm_arc_machine.server
  description = "The arc server object"
}
