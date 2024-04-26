terraform {
  backend "azurerm" {
    resource_group_name  = "bugBashV1"
    storage_account_name = "iactestingwen"
    container_name       = "iactestingcontainer"
    key                  = "{{.GroupName}}.tfstate"
  }
}