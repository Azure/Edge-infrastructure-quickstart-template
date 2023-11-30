variable "siteId" {
  description = "A unique identifier for the site."
  type        = string
}

variable "resourceGroup" {
  description = "The resource group for the Azure Stack HCI cluster."
}

variable "clusterId" {
  description = "The resource ID for the Azure Stack HCI cluster."
  type        = string
}

variable "serverNames" {
  description = "A list of servers with their names."
  type        = list(string)
}

variable "arcSettingId" {
  description = "The resource ID for the Azure Arc setting."
  type        = string
}
