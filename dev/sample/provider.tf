provider "azurerm" {
  features {
  }
  subscription_id = var.subscriptionId
  skip_provider_registration = true
}

provider "azapi" {
  subscription_id = var.subscriptionId
}
