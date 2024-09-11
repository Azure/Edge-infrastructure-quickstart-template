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
