terraform {
  backend "azurerm" {
    resource_group_name  = "AdaptiveCloud-IaC"
    storage_account_name = "adaptivecloudiac"
    container_name       = "ac-iac"
    key                  = "Arizona.tfstate"
  }
}
