resource "azurerm_storage_account" "witness" {
  name                     = var.randomSuffix ? "${var.witnessStorageAccountName}${random_integer.random_suffix.result}" : var.witnessStorageAccountName
  location                 = var.resourceGroup.location
  resource_group_name      = var.resourceGroup.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
