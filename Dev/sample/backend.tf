terraform {
  backend "azurerm" {
    resource_group_name  = "terraformbackend"
    storage_account_name = "demobackend"
    container_name       = "tfbackend"
    key                  = "terraform.tfstate"
  }
}