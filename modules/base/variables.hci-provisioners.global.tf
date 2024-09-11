variable "enable_provisioners" {
  type        = bool
  default     = true
  description = "Whether to enable provisioners."
}

variable "dc_ip" {
  type        = string
  description = "The ip of the server."
}

variable "destory_adou" {
  description = "whether destroy previous adou"
  default     = false
  type        = bool
}

variable "authentication_method" {
  type        = string
  description = "The authentication method for Enter-PSSession."
  validation {
    condition     = can(regex("^(Default|Basic|Negotiate|NegotiateWithImplicitCredential|Credssp|Digest|Kerberos)$", var.authentication_method))
    error_message = "Value of authenticationMethod should be {Default | Basic | Negotiate | NegotiateWithImplicitCredential | Credssp | Digest | Kerberos}"
  }
  default = "Default"
}
