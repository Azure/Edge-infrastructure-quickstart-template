variable "enableAksArc" {
  description = "Whether to enable hybrid aks."
  type        = bool
  default     = false
}

# Hybrid AKS related variables

variable "aksArc-controlPlaneIp" {
  type        = string
  description = "The IP address of the control plane."
  default     = ""
}

variable "aksArc-lnet-addressPrefix" {
  type        = string
  description = "The CIDR prefix of the subnet that start from startting address and end with ending address, this can be omit if using existing logical network"
  default     = ""
}

variable "aksArc-lnet-startingAddress" {
  type        = string
  description = "The starting IP address of the IP address range of the logical network, this can be omit if using existing logical network"
  default     = ""
}

variable "aksArc-lnet-endingAddress" {
  type        = string
  description = "The ending IP address of the IP address range of the logical network, this can be omit if using existing logical network"
  default     = ""
}

variable "aksArc-lnet-vlanId" {
  type        = string
  description = "The vlan id of the logical network, default is not set vlan id, this can be omit if using existing logical network"
  default     = null
}

variable "aksArc-lnet-usingExistingLogicalNetwork" {
  type        = bool
  description = "Whether using existing logical network"
  default     = false
}

variable "aksArc-lnet-dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
  default     = []
  
}

variable "aksArc-lnet-defaultGateway" {
  type        = string
  description = "The default gateway for the network."
  default     = null
}
