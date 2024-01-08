//Authorize RP
locals {
  SPRoleList = [
    # "Azure Connected Machine Resource Manager",
    "User Access Administrator",
    "Contributor"
  ]
}

data "azuread_service_principal" "hciRp" {
  count      = var.rpServicePrincipalObjectId == "" ? 1 : 0
  client_id = "1412d89f-b8a8-4111-b4fd-e82905cbd85d"
}

resource "azurerm_role_assignment" "ServicePrincipalRoleAssign" {
  for_each             = toset(local.SPRoleList)
  scope                = var.resourceGroup.id
  role_definition_name = each.value
  principal_id         = var.rpServicePrincipalObjectId == "" ? data.azuread_service_principal.hciRp[0].object_id : var.rpServicePrincipalObjectId
}

module "serverRoleBindings" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  source        = "./server-rolebindings"
  resourceGroup = var.resourceGroup
  serverName    = each.key
  subId         = var.subId
}
