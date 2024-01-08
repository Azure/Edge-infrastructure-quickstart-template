locals {
  resourceGroupName         = "${var.siteId}-rg"
  witnessStorageAccountName = "${var.siteId}wit"
  keyvaultName              = "${var.siteId}-kv"
}
