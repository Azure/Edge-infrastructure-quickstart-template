terraform {
  backend "azurerm" {
    resource_group_name  = "<ResourceGroupName>"    # TODO: Replace with your Resource Group Name
    storage_account_name = "<StorageAccountName>"   # TODO: Replace with your Storage Account Name
    container_name       = "<StorageContainerName>" # TODO: Replace with your Storage Container Name
    key                  = "{{.GroupName}}.tfstate"
  }
}

# TODO: run `git config --local core.hooksPath ./.azure/hooks/` to enable automatic backend configuration
