# Potential global variables
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

# Reference variables
  # variable "siteId"       "ref/main/siteId"
  # variable "serverNames"  "ref/hci/servers" "serverNames = [for server in var.servers : server.name]"
