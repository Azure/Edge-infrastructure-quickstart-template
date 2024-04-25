provider "azurerm" {
  features {
  }
  subscription_id = var.subscriptionId
}

provider "azapi" {
  subscription_id = var.subscriptionId
}
