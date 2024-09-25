variable "lnet_dns_servers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
  default     = []
}

variable "lnet_default_gateway" {
  type        = string
  description = "The default gateway for the network."
  default     = ""
}

variable "logical_network_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the logical network."
}

variable "route_name" {
  type        = string
  default     = "default"
  description = "The name of the route"
}

variable "subnet_0_name" {
  type        = string
  default     = "default"
  description = "The name of the subnet"
}
