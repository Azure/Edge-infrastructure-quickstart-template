locals {
  resourceGroupName          = "${var.siteId}"
  siteResourceName           = "${var.siteId}"
  siteDisplayName            = "${var.siteId}"
  addressResourceName        = "${var.siteId}-address"
  deploymentUserName         = "${var.siteId}deploy"
  witnessStorageAccountName  = "${lower(var.siteId)}wit"
  keyvaultName               = "${var.siteId}-kv"
  adouPath                   = "OU=${var.siteId},${var.adouSuffix}"
  clusterName                = "${var.siteId}"
  customLocationName         = "${var.siteId}"
  workspaceName              = "AdaptiveCloud-LAW-EUS"
  dataCollectionEndpointName = "${var.siteId}-dce"
  dataCollectionRuleName     = "AzureStackHCI-${var.siteId}-dcr"
  aksArcName                 = "${var.siteId}-aksArc"
  logicalNetworkName         = "${var.siteId}-logicalnetwork"
  randomSuffix               = true
}
