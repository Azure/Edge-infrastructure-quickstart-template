module "servers" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  depends_on             = [terraform_data.ad_creation_provisioner]
  source                 = "./hci-server"
  resourceGroup          = var.resourceGroup.name
  serverName             = each.key
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  serverIP               = var.virtualHostIp == "" ? each.value : var.virtualHostIp
  winrmPort              = var.virtualHostIp == "" ? 5985 : var.serverPorts[each.key]
  subId                  = var.subId
  location               = var.resourceGroup.location
  tenant                 = var.tenant
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  expandC                = var.virtualHostIp == "" ? false : true
}
