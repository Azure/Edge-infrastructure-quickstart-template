# Potential global variables
  variable "kubernetesVersion" {
    description = "The version of Kubernetes to use for the provisioned cluster."
    type        = string
    default     = "1.25.11"
  }

  variable "controlPlaneCount" {
    description = "The number of control plane nodes for the Kubernetes cluster."
    type        = number
    default     = 1
  }

  variable "agentPoolProfiles" {
    description = "The agent pool profiles for the Kubernetes cluster."
    type = list(object({
      count             = number
      enableAutoScaling = bool
      nodeTaints        = list(string)
      nodeLabels        = map(string)
      maxPods           = number
      name              = string
      osSKU             = string
      osType            = string
      vmSize            = string
    }))
    default = [{
      count            = 1
      enableAutoScaling = false
    }]
  }

  variable "enableAzureRBAC" {
    description = "Whether to enable Azure RBAC for the Kubernetes cluster."
    type        = bool
    default     = false
  }

  variable "rbacAdminGroupObjectId" {
    description = "The object id of the Azure AD group that will be assigned the 'cluster-admin' role in the Kubernetes cluster."
    type        = list(string)
    default     = []
  }

# Site specific variables
  variable "aksArc-controlPlaneIp" {
    type        = string
    description = "The IP address of the control plane."
  }

  variable "aksArc-lnet-addressPrefix" {
    type        = string
    description = "The CIDR prefix of the subnet that start from startting address and end with ending address, this can be omit if using existing logical network"
  }

  variable "aksArc-lnet-startingAddress" {
    type        = string
    description = "The starting IP address of the IP address range of the logical network, this can be omit if using existing logical network"
  }

  variable "aksArc-lnet-endingAddress" {
    type        = string
    description = "The ending IP address of the IP address range of the logical network, this can be omit if using existing logical network"
  }

  variable "aksArc-lnet-vlanId" {
    type        = number
    description = "The vlan id of the logical network, default is not set vlan id, this can be omit if using existing logical network"
    default     = null
  }

  variable "aksArc-lnet-dnsServers" {
    type        = list(string)
    description = "A list of DNS server IP addresses."
  }

  variable "aksArc-lnet-defaultGateway" {
    type        = string
    description = "The default gateway for the network."
  }

# Reference variables
  # variable "tenant" "ref/hci/tenant"
