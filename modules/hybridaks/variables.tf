variable "resourceGroup" {
  description = "The resource group where the resources will be deployed."
}

variable "customLocationId" {
  description = "The id of the Custom location that used to create hybrid aks"
  type        = string
}

variable "hybridAksName" {
  type        = string
  description = "The name of the hybrid aks"
}

variable "logicalNetworkName" {
  type        = string
  description = "The name of the logical network"
}

variable "controlPlaneIp" {
  type        = string
  description = "the ip address of the control plane"
}

variable "usingExistingLogicalNetwork" {
  type        = bool
  description = "Whether using existing logical network"
  default     = false
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
  description = "the vlan id of the logical network, default means no vlan id is specified"
  default     = null
}

variable "enableAzureRBAC" {
  type        = bool
  description = "whether to enable azure rbac"
  default     = false
}

variable "azureRBACTenantId" {
  type        = string
  description = "the tenant id of the azure rbac"
  default     = ""
}

variable "rbacAdminGroupObjectId" {
  type        = list(string)
  description = "the object id of the admin group of the azure rbac"
  default     = []
}

variable "kubernetesVersion" {
  type        = string
  description = "the kubernetes version"
  default     = "v1.26.6"
}

variable "controlPlaneCount" {
  type        = number
  description = "the count of the control plane"
  default     = 1
}

variable "workerCount" {
  type        = number
  description = "the count of the worker"
  default     = 1
}
