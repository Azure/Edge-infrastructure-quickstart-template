locals {
  resourceGroupName          = "${var.siteId}-rg"
  witnessStorageAccountName  = "${var.siteId}wit"
  keyvaultName               = "${var.siteId}-kv"
  clusterName                = "${var.siteId}-cl"
  customLocationName         = "${var.siteId}-customlocation"
  workspaceName              = "${var.siteId}-workspace"
  dataCollectionEndpointName = "${var.siteId}-dce"
  dataCollectionRuleName     = "AzureStackHCI-${var.siteId}-dcr"
  randomSuffix               = true
}
