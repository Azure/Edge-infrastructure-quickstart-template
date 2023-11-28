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

variable "enableInsights" {
  description = "Whether to enable Azure Monitor Insights."
  type        = bool
  default     = true
}

variable "enableAlerts" {
  description = "Whether to enable Azure Monitor Alerts."
  type        = bool
  default     = true
}
