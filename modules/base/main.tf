resource "azurerm_resource_group" "rg" {
  name     = local.resourceGroupName
  location = var.location
  tags     = {}
}

//Prepare AD and arc server
module "hci-provisioners" {
  depends_on             = [azurerm_resource_group.rg]
  count                  = var.enableProvisioners ? 1 : 0
  source                 = "../hci-provisioners"
  resourceGroup          = azurerm_resource_group.rg
  siteId                 = var.siteId
  domainFqdn             = var.domainFqdn
  adouPath               = var.adouPath
  tenant                 = var.tenant
  domainServerIP         = var.domainServerIP
  domainAdminUser        = var.domainAdminUser
  domainAdminPassword    = var.domainAdminPassword
  authenticationMethod   = var.authenticationMethod
  servers                = var.servers
  clusterName            = local.clusterName
  subId                  = var.subId
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  deploymentUserName     = var.deploymentUserName
  deploymentUserPassword = var.deploymentUserPassword
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  destory_adou           = var.destory_adou
  virtualHostIp          = var.virtualHostIp
  dcPort                 = var.dcPort
  serverPorts            = var.serverPorts
}

module "hci" {
  depends_on                 = [module.hci-provisioners]
  source                     = "../hci"
  resourceGroup              = azurerm_resource_group.rg
  siteId                     = var.siteId
  domainFqdn                 = var.domainFqdn
  startingAddress            = var.startingAddress
  endingAddress              = var.endingAddress
  defaultGateway             = var.defaultGateway
  dnsServers                 = var.dnsServers
  adouPath                   = var.adouPath
  tenant                     = var.tenant
  servers                    = var.servers
  managementAdapters         = var.managementAdapters
  storageNetworks            = var.storageNetworks
  clusterName                = local.clusterName
  customLocationName         = local.customLocationName
  witnessStorageAccountName  = local.witnessStorageAccountName
  keyvaultName               = local.keyvaultName
  randomSuffix               = local.randomSuffix
  subId                      = var.subId
  deploymentUserName         = var.deploymentUserName
  deploymentUserPassword     = var.deploymentUserPassword
  localAdminUser             = var.localAdminUser
  localAdminPassword         = var.localAdminPassword
  servicePrincipalId         = var.servicePrincipalId
  servicePrincipalSecret     = var.servicePrincipalSecret
  rpServicePrincipalObjectId = var.rpServicePrincipalObjectId
}

locals {
  serverNames = [for server in var.servers : server.name]
}

module "extension" {
  source                     = "../hci-extensions"
  depends_on                 = [module.hci]
  resourceGroup              = azurerm_resource_group.rg
  siteId                     = var.siteId
  arcSettingsId              = module.hci.arcSettings.id
  serverNames                = local.serverNames
  workspaceName              = local.workspaceName
  dataCollectionEndpointName = local.dataCollectionEndpointName
  dataCollectionRuleName     = local.dataCollectionRuleName
  enableInsights             = var.enableInsights
  enableAlerts               = var.enableAlerts
}

module "vm" {
  count            = var.enableVM ? 1 : 0
  source           = "../hci-vm"
  depends_on       = [module.hci]
  customLocationId = module.hci.customlocation.id
  resourceGroupId  = azurerm_resource_group.rg.id
  userStorageId    = module.hci.userStorages[0].id
  location         = azurerm_resource_group.rg.location
}
