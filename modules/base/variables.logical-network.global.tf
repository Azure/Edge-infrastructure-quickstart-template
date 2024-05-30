variable "lnet-dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
  default     = []
}

variable "lnet-defaultGateway" {
  type        = string
  description = "The default gateway for the network."
  default     = ""
}
