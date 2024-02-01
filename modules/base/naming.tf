/***
  ${var.siteId} is the identifier of a site
  ${var.siteName} is the name of a site, which can be used to name resources as well.
  When using ${var.siteName} to name resources, you need to make sure that the name is unique across all sites.
  It's recommended to remove the default value of ${var.siteName} in variables.tf.
***/

locals {
  resourceGroupName          = "${var.siteId}-rg"
  witnessStorageAccountName  = "${var.siteId}wit"
  keyvaultName               = "${var.siteId}-kv"
  clusterName                = "${var.siteId}-cl"
  customLocationName         = "${var.siteId}-customlocation"
  workspaceName              = "${var.siteId}-workspace"
  dataCollectionEndpointName = "${var.siteId}-dce"
  dataCollectionRuleName     = "AzureStackHCI-${var.siteId}-dcr"
  aksArcName              = "${var.siteId}-aksArc"
  logicalNetworkName         = "${var.siteId}-logicalnetwork"
  randomSuffix               = true
}
