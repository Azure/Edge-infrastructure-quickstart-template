variable "resourceGroup" {
  description = "The resource group where the resources will be deployed."
}

variable "customLocationId" {
  description = "The id of the Custom location that used to create hybrid aks"
  type        = string
}

variable "startingAddress" {
  description = "The starting IP address of the IP address range."
  type        = string
}

variable "endingAddress" {
  description = "The ending IP address of the IP address range."
  type        = string
}

variable "defaultGateway" {
  description = "The default gateway for the network."
  type        = string
}

variable "dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
}

variable "addressPrefix" {
  type    = string
  description = "The CIDR prefix of the subnet that used by kubernetes cluster nodes, it will create VM with the ip address in this range" 
}

variable "hybridAksName" {
  type        = string
  description = "The name of the hybrid aks"
}

variable "logicalNetworkName" {
  type        = string
  description = "The name of the logical network"
}