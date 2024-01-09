variable "siteId" {
  description = "A unique identifier for the site."
  type        = string
}

variable "resourceGroup" {
  description = "The resource group for the Azure Stack HCI cluster."
}

variable "serverNames" {
  description = "A list of servers with their names."
  type        = list(string)
}

variable "arcSettingId" {
  description = "The resource ID for the Azure Arc setting."
  type        = string
}

variable "workspaceName" {
  description = "The name of the Azure Log Analytics workspace."
  type        = string
}

variable "dataCollectionRuleName" {
  description = "The name of the Azure Log Analytics data collection rule."
  type        = string
}

variable "dataCollectionEndpointName" {
  description = "The name of the Azure Log Analytics data collection endpoint."
  type        = string
}
