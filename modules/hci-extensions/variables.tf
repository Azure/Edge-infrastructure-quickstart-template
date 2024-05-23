variable "siteId" {
  description = "A unique identifier for the site."
  type        = string
}

variable "resourceGroup" {
  description = "The resource group for the Azure Stack HCI cluster."
}

variable "arcSettingsId" {
  description = "The resource ID for the Azure Stack HCI cluster arc settings."
  type        = string
}

variable "serverNames" {
  description = "A list of servers with their names."
  type        = list(string)
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

variable "enableInsights" {
  description = "Whether to enable Azure Monitor Insights."
  type        = bool
  default     = false
}

variable "enableAlerts" {
  description = "Whether to enable Azure Monitor Alerts."
  type        = bool
  default     = false
}
