provider "azurerm" {
  features {
  }
  subscription_id = hci.var.subId
}

provider "azapi" {
  subscription_id = hci.var.subId
}
