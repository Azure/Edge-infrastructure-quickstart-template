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
