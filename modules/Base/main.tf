locals {
  serverNames = [for server in var.servers : server.name]
}

module "hci" {
  source                = "../hci"
  location              = var.location
  siteId                = var.siteId
  domainFqdn            = var.domainFqdn
  startingAddress       = var.startingAddress
  endingAddress         = var.endingAddress
  defaultGateway        = var.defaultGateway
  dnsServers            = var.dnsServers
  adouPath              = var.adouPath
  tenant                = var.tenant
  domainServerIP        = var.domainServerIP
  servers               = var.servers
  managementAdapters    = var.managementAdapters
  storageNetworks       = var.storageNetworks
  subId                 = var.subId
  domainAdminUser       = var.domainAdminUser
  domainAdminPassword   = var.domainAdminPassword
  localAdminUser        = var.localAdminUser
  localAdminPassword    = var.localAdminPassword
  servicePricipalId     = var.servicePricipalId
  servicePricipalSecret = var.servicePricipalSecret
  destory_adou          = var.destory_adou
  virtualHostIp         = var.virtualHostIp
  dcPort                = var.dcPort
  serverPorts           = var.serverPorts
}

module "extension" {
  source         = "../hci-extensions"
  depends_on     = [module.hci]
  resourceGroup  = module.hci.resourceGroup
  siteId         = var.siteId
  clusterId      = module.hci.cluster.id
  serverNames    = local.serverNames
  enableInsights = false
  enableAlerts   = false
}

module "vm" {
  count            = 0
  source           = "../hci-vm"
  depends_on       = [module.hci]
  customLocationId = module.hci.customlocation.id
  resourceGroupId  = module.hci.resourceGroup.id
  userStorageId    = module.hci.userStorage1.id
  location         = module.hci.resourceGroup.location
}
