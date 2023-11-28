variable "customLocationId" {
  description = "The custom location ID for the Azure Stack HCI cluster."
  type        = string
}

variable "userStorageId" {
  description = "The user storage ID to store images."
  type        = string
}

variable "resourceGroupId" {
  description = "The resource group ID for the Azure Stack HCI cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}
