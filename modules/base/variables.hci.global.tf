variable "domain_fqdn" {
  description = "The domain FQDN."
  type        = string
}

variable "adou_suffix" {
  type        = string
  description = "The suffix of Active Directory OU path."
}

variable "subnet_mask" {
  type        = string
  description = "The subnet mask for the network."
  default     = "255.255.255.0"
}

variable "default_gateway" {
  description = "The default gateway for the network."
  type        = string
}

variable "dns_servers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
}

variable "management_adapters" {
  type    = list(string)
}

variable "storage_networks" {
  type = list(object({
    name               = string
    networkAdapterName = string
    vlanId             = string
  }))
}

variable "rdma_enabled" {
  type        = bool
  description = "Indicates whether RDMA is enabled."
}

variable "storage_connectivity_switchless" {
  type        = bool
  description = "Indicates whether storage connectivity is switchless."
}
