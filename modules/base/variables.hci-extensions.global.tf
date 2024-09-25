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

variable "cmk_for_query_forced" {
  type        = bool
  default     = false
  description = "(Optional) Is Customer Managed Storage mandatory for query management?"
}

variable "counter_specifiers" {
  type = list(string)
  default = [
    "\\Memory\\Available Bytes",
    "\\Network Interface(*)\\Bytes Total/sec",
    "\\Processor(_Total)\\% Processor Time",
    "\\RDMA Activity(*)\\RDMA Inbound Bytes/sec",
    "\\RDMA Activity(*)\\RDMA Outbound Bytes/sec"
  ]
  description = "A list of performance counter specifiers."
}

variable "data_collection_endpoint_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to th data collection endpoint."
}

variable "data_collection_rule_destination_id" {
  type        = string
  default     = "2-90d1-e814dab6067e"
  description = "The id of data collection rule destination id."
}

variable "data_collection_rule_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to th data collection rule."
}

variable "immediate_data_purge_on_30_days_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to remove the data in the Log Analytics Workspace immediately after 30 days."
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
}

variable "sku" {
  type        = string
  default     = "PerGB2018"
  description = " (Optional) Specifies the SKU of the Log Analytics Workspace."
}

variable "workspace_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the Azure Log Analytics workspace."
}

variable "x_path_queries" {
  type = list(string)
  default = [
    "Microsoft-Windows-SDDC-Management/Operational!*[System[(EventID=3000 or EventID=3001 or EventID=3002 or EventID=3003 or EventID=3004)]]",
    "microsoft-windows-health/operational!*"
  ]
  description = "A list of XPath queries for event logs."
}
