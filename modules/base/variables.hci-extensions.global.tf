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
