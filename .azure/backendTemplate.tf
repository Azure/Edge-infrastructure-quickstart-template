terraform {
  backend "azurerm" {
    resource_group_name  = "IacAutomationTest-hangxu"
    storage_account_name = "iacautomationbackhangxu"
    container_name       = "tfbackend"
    key                  = "sample.tfstate"
  }
}
