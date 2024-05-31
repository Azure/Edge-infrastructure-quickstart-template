resource "azurerm_resource_group" "rg" {
  depends_on = [
    data.external.lnetIpCheck
  ]
  name     = local.resourceGroupName
  location = var.location
  tags = {
    siteId = var.siteId
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

module "site-manager" {
  source              = "../site-manager"
  siteResourceName    = local.siteResourceName
  siteDisplayName     = local.siteDisplayName
  addressResourceName = local.addressResourceName
  resourceGroup       = azurerm_resource_group.rg
  country             = var.country
  city                = var.city
  companyName         = var.companyName
  postalCode          = var.postalCode
  stateOrProvince     = var.stateOrProvince
  streetAddress1      = var.streetAddress1
  streetAddress2      = var.streetAddress2
  streetAddress3      = var.streetAddress3
  zipExtendedCode     = var.zipExtendedCode
  contactName         = var.contactName
  emailList           = var.emailList
  mobile              = var.mobile
  phone               = var.phone
  phoneExtension      = var.phoneExtension
}

//Prepare AD and arc server
module "hci-provisioners" {
  depends_on             = [azurerm_resource_group.rg]
  count                  = var.enableProvisioners ? 1 : 0
  source                 = "../hci-provisioners"
  resourceGroup          = azurerm_resource_group.rg
  siteId                 = var.siteId
  domainFqdn             = var.domainFqdn
  adouPath               = local.adouPath
  domainServerIP         = var.domainServerIP
  domainAdminUser        = var.domainAdminUser
  domainAdminPassword    = var.domainAdminPassword
  authenticationMethod   = var.authenticationMethod
  servers                = var.servers
  clusterName            = local.clusterName
  subscriptionId         = var.subscriptionId
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  deploymentUser         = local.deploymentUserName
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
  subnetMask                    = var.subnetMask
  startingAddress               = var.startingAddress
  endingAddress                 = var.endingAddress
  defaultGateway                = var.defaultGateway
  dnsServers                    = var.dnsServers
  adouPath                      = local.adouPath
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
  deploymentUser                = local.deploymentUserName
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

module "logical-network" {
  source             = "../hci-logical-network"
  depends_on         = [module.hci]
  resourceGroupId    = azurerm_resource_group.rg.id
  location           = azurerm_resource_group.rg.location
  customLocationId   = module.hci.customlocation.id
  logicalNetworkName = local.logicalNetworkName
  vmSwitchName       = module.hci.vSwitchName
  startingAddress    = var.lnet-startingAddress
  endingAddress      = var.lnet-endingAddress
  dnsServers         = var.lnet-dnsServers == [] ? var.dnsServers : var.lnet-dnsServers
  defaultGateway     = var.lnet-defaultGateway == "" ? var.defaultGateway : var.lnet-defaultGateway
  addressPrefix      = var.lnet-addressPrefix
  vlanId             = var.lnet-vlanId
}

module "aks-arc" {
  source                  = "../aks-arc"
  depends_on              = [module.hci]
  customLocationId        = module.hci.customlocation.id
  resourceGroup           = azurerm_resource_group.rg
  logicalNetworkId        = module.logical-network.logicalNetworkId
  agentPoolProfiles       = var.agentPoolProfiles
  sshKeyVaultId           = module.hci.keyvault.id
  aksArcName              = local.aksArcName
  controlPlaneIp          = var.aksArc-controlPlaneIp
  arbId                   = module.hci.arcbridge.id
  kubernetesVersion       = var.kubernetesVersion
  controlPlaneCount       = var.controlPlaneCount
  rbacAdminGroupObjectIds = var.rbacAdminGroupObjectIds
}

module "vm-image" {
  source                 = "../hci-vm-gallery-image"
  depends_on             = [module.hci]
  customLocationId       = module.hci.customlocation.id
  resourceGroupId        = azurerm_resource_group.rg.id
  location               = azurerm_resource_group.rg.location
  downloadWinServerImage = var.downloadWinServerImage
}

module "vm" {
  count               = var.downloadWinServerImage ? 1 : 0
  source              = "../hci-vm"
  depends_on          = [module.vm-image]
  location            = azurerm_resource_group.rg.location
  customLocationId    = module.hci.customlocation.id
  resourceGroupId     = azurerm_resource_group.rg.id
  vmName              = local.vmName
  imageId             = module.vm-image.winServerImageId
  logicalNetworkId    = module.logical-network.logicalNetworkId
  adminUsername       = local.vmAdminUsername
  adminPassword       = var.vmAdminPassword
  vCPUCount           = var.vCPUCount
  memoryMB            = var.memoryMB
  dynamicMemory       = var.dynamicMemory
  dynamicMemoryMax    = var.dynamicMemoryMax
  dynamicMemoryMin    = var.dynamicMemoryMin
  dynamicMemoryBuffer = var.dynamicMemoryBuffer
  dataDiskParams      = var.dataDiskParams
  privateIPAddress    = var.privateIPAddress
  domainToJoin        = var.domainToJoin
  domainTargetOu      = var.domainTargetOu
  domainJoinUserName  = var.domainJoinUserName
  domainJoinPassword  = var.domainJoinPassword
}
