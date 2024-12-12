terraform {
  backend "azurerm" {
    resource_group_name  = "jundachen"
    storage_account_name = "jundacheniac"
    container_name       = "iac"
    key                  = "{{.GroupName}}.tfstate"
  }
}