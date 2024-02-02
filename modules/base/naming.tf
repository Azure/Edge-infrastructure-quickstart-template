locals {
  resourceGroupName          = "${var.siteId}-rg"
  witnessStorageAccountName  = "${lower(var.siteId)}wit"
  keyvaultName               = "${var.siteId}-kv"
  clusterName                = "${var.siteId}-cl"
  customLocationName         = "${var.siteId}-customlocation"
  workspaceName              = "${var.siteId}-workspace"
  dataCollectionEndpointName = "${var.siteId}-dce"
  dataCollectionRuleName     = "AzureStackHCI-${var.siteId}-dcr"
  aksArcName                 = "${var.siteId}-aksArc"
  logicalNetworkName         = "${var.siteId}-logicalnetwork"
  randomSuffix               = true
}
