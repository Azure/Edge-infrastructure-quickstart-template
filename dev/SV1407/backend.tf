terraform {
  backend "azurerm" {
    resource_group_name  = "RG_SUPERMARKETSTORES_HCIPLATFORM_SV1407_NONPROD_AUE"
    storage_account_name = "storesiacterraform1407"
    container_name       = "terraformiac"
    key                  = "SV1407.tfstate"
  }
}
