variable "resourceGroupId" {
  description = "The resource group ID for the Azure Stack HCI logical network."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "customLocationId" {
  description = "The id of the Custom location that used to create hybrid aks"
  type        = string
}

variable "logicalNetworkName" {
  type        = string
  description = "The name of the logical network"
}

variable "vmSwitchName" {
  description = "The name of the virtual switch that is used by the network."
  type        = string
}

variable "startingAddress" {
  description = "The starting IP address of the IP address range."
  type        = string
  default     = null
}

variable "endingAddress" {
  description = "The ending IP address of the IP address range."
  type        = string
  default     = null
}

variable "defaultGateway" {
  description = "The default gateway for the network."
  type        = string
  default     = null
}

variable "dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
  default     = []
}

variable "addressPrefix" {
  type        = string
  description = "The CIDR prefix of the subnet that used by kubernetes cluster nodes, it will create VM with the ip address in this range"
  default     = null
}

variable "vlanId" {
  type        = string
  description = "The vlan id of the logical network, default means no vlan id is specified"
  default     = null
}
