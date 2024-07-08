variable "kubernetesVersion" {
  description = "The version of Kubernetes to use for the provisioned cluster."
  type        = string
  default     = "1.28.5"
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
    enableAutoScaling = optional(bool, false)
    nodeTaints        = optional(list(string))
    nodeLabels        = optional(map(string))
    maxPods           = optional(number)
    name              = optional(string)
    osSKU             = optional(string, "CBLMariner")
    osType            = optional(string, "Linux")
    vmSize            = optional(string)
  }))
  default = [{
    count             = 1
    enableAutoScaling = false
  }]
}

variable "rbacAdminGroupObjectIds" {
  description = "The object id of the Azure AD group that will be assigned the 'cluster-admin' role in the Kubernetes cluster."
  type        = list(string)
  # Add your default admin groups here. Refer to the documentation under doc/AKS-Arc-Admin-Groups.md for more information.
  # default     = ["<your-admin-group-object-id>"]
}
