variable "enable_insights" {
  description = "Whether to enable Azure Monitor Insights."
  type        = bool
  default     = false
}

variable "enable_alerts" {
  description = "Whether to enable Azure Monitor Alerts."
  type        = bool
  default     = false
}

variable "data_collection_rule_resource_id" {
  type        = string
  description = "The id of the Azure Log Analytics data collection rule."
  default     = ""
}
