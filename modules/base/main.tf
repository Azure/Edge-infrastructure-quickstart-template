locals {
  serverNames = [for server in var.servers : server.name]
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.siteId}-rg"
  location = var.location
  tags     = {}
}

module "hci-provisioners" {
  count                  = var.enableProvisioners ? 1 : 0
  source                 = "../hci-provisioners"
  resourceGroup          = azurerm_resource_group.rg
  siteId                 = var.siteId
  domainFqdn             = var.domainFqdn
  adouPath               = var.adouPath
  tenant                 = var.tenant
  domainServerIP         = var.domainServerIP
  servers                = var.servers
  subId                  = var.subId
  domainAdminUser        = var.domainAdminUser
  domainAdminPassword    = var.domainAdminPassword
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  destory_adou           = var.destory_adou
  virtualHostIp          = var.virtualHostIp
  dcPort                 = var.dcPort
  serverPorts            = var.serverPorts
}

module "hci" {
  source                 = "../hci"
  depends_on             = [module.hci-provisioners]
  resourceGroup          = azurerm_resource_group.rg
  siteId                 = var.siteId
  domainFqdn             = var.domainFqdn
  startingAddress        = var.startingAddress
  endingAddress          = var.endingAddress
  defaultGateway         = var.defaultGateway
  dnsServers             = var.dnsServers
  adouPath               = var.adouPath
  tenant                 = var.tenant
  domainServerIP         = var.domainServerIP
  servers                = var.servers
  managementAdapters     = var.managementAdapters
  storageNetworks        = var.storageNetworks
  subId                  = var.subId
  domainAdminUser        = var.domainAdminUser
  domainAdminPassword    = var.domainAdminPassword
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  destory_adou           = var.destory_adou
}

module "extension" {
  source         = "../hci-extensions"
  depends_on     = [module.hci]
  resourceGroup  = module.hci.resourceGroup
  siteId         = var.siteId
  clusterId      = module.hci.cluster.id
  serverNames    = local.serverNames
  enableInsights = var.enableInsights
  enableAlerts   = var.enableAlerts
}

module "vm" {
  count            = var.enableVM ? 1 : 0
  source           = "../hci-vm"
  depends_on       = [module.hci]
  customLocationId = module.hci.customlocation.id
  resourceGroupId  = module.hci.resourceGroup.id
  userStorageId    = module.hci.userStorage1.id
  location         = module.hci.resourceGroup.location
}
