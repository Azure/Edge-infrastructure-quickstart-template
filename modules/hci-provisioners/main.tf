data "azurerm_client_config" "current" {}

module "servers" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  depends_on             = [terraform_data.ad_creation_provisioner]
  source                 = "./hci-server"
  resourceGroupName      = var.resourceGroup.name
  serverName             = each.key
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  authenticationMethod   = var.authenticationMethod
  serverIP               = var.virtualHostIp == "" ? each.value : var.virtualHostIp
  winrmPort              = var.virtualHostIp == "" ? 5985 : var.serverPorts[each.key]
  subscriptionId         = var.subscriptionId
  location               = var.resourceGroup.location
  tenant                 = data.azurerm_client_config.current.tenant_id
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  expandC                = var.virtualHostIp == "" ? false : true
}
resource "terraform_data" "replacement" {
  input = var.resourceGroup.name
}

output "servers" {
  value = module.servers
}
