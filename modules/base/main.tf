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
  subscriptionId         = var.subscriptionId
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
  depends_on                    = [module.hci-provisioners]
  source                        = "../hci"
  resourceGroup                 = azurerm_resource_group.rg
  siteId                        = var.siteId
  domainFqdn                    = var.domainFqdn
  startingAddress               = var.startingAddress
  endingAddress                 = var.endingAddress
  defaultGateway                = var.defaultGateway
  dnsServers                    = var.dnsServers
  adouPath                      = var.adouPath
  tenant                        = var.tenant
  servers                       = var.servers
  managementAdapters            = var.managementAdapters
  storageNetworks               = var.storageNetworks
  rdmaEnabled                   = var.rdmaEnabled
  storageConnectivitySwitchless = var.storageConnectivitySwitchless
  clusterName                   = local.clusterName
  customLocationName            = local.customLocationName
  witnessStorageAccountName     = local.witnessStorageAccountName
  keyvaultName                  = local.keyvaultName
  randomSuffix                  = local.randomSuffix
  subscriptionId                = var.subscriptionId
  deploymentUserName            = var.deploymentUserName
  deploymentUserPassword        = var.deploymentUserPassword
  localAdminUser                = var.localAdminUser
  localAdminPassword            = var.localAdminPassword
  servicePrincipalId            = var.servicePrincipalId
  servicePrincipalSecret        = var.servicePrincipalSecret
  rpServicePrincipalObjectId    = var.rpServicePrincipalObjectId
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

module "hybridaks" {
  source                      = "../hybridaks"
  depends_on                  = [module.hci]
  count                       = var.enableHybridAKS ? 1 : 0
  customLocationId            = module.hci.customlocation.id
  resourceGroup               = azurerm_resource_group.rg
  startingAddress             = var.hybridAks-lnet-startingAddress
  endingAddress               = var.hybridAks-lnet-endingAddress
  dnsServers                  = var.hybridaks-lnet-dnsServers
  defaultGateway              = var.hybridaks-lnet-defaultGateway
  addressPrefix               = var.hybridAks-lnet-addressPrefix
  logicalNetworkName          = local.logicalNetworkName
  hybridAksName               = local.hybridAksName
  usingExistingLogicalNetwork = var.hybridaks-lnet-usingExistingLogicalNetwork
  vlanId                      = var.hybridaks-lnet-vlanId
  controlPlaneIp              = var.hybridAks-controlPlaneIp
  arbId                       = module.hci.arcbridge.id
}
