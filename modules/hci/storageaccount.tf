# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {}
  byte_length = 8
}

resource "azurerm_storage_account" "witness" {
  name                     = "wit${random_id.random_id.hex}"
  location                 = var.resourceGroup.location
  resource_group_name      = var.resourceGroup.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
