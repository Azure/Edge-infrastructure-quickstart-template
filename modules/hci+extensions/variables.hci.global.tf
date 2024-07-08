variable "domainFqdn" {
  description = "The domain FQDN."
  type        = string
}

variable "adouSuffix" {
  type        = string
  description = "The suffix of Active Directory OU path."
}

variable "subnetMask" {
  default     = "255.255.255.0"
  type        = string
  description = "The subnet mask for the network."
}

variable "defaultGateway" {
  description = "The default gateway for the network."
  type        = string
}

variable "dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
}

variable "managementAdapters" {
  type    = list(string)
  default = ["ethernet", "ethernet 2"]
}

variable "storageNetworks" {
  type = list(object({
    name               = string
    networkAdapterName = string
    vlanId             = string
  }))
}

variable "rdmaEnabled" {
  type        = bool
  description = "Indicates whether RDMA is enabled."
}

variable "storageConnectivitySwitchless" {
  type        = bool
  description = "Indicates whether storage connectivity is switchless."
}
