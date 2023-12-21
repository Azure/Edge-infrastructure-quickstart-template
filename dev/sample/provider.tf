provider "azurerm" {
  skip_provider_registration = true
  features {
    
  }
  subscription_id = var.subscriptionId
}

provider "azapi" {
  subscription_id = var.subscriptionId
}
