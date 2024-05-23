variable "siteResourceName" {
  description = "A resource name for the site."
  type        = string
}

variable "siteDisplayName" {
  description = "A display name for the site."
  type        = string
}

variable "addressResourceName" {
  description = "A resource name for the address."
  type        = string
}

variable "resourceGroup" {
  description = "The resource group of the site."
}

variable "country" {
  description = "The order country of the site."
  type        = string
  default     = ""
}

variable "city" {
  description = "The city of the site."
  type        = string
  default     = ""
}

variable "companyName" {
  description = "The company name of the site."
  type        = string
  default     = ""
}

variable "postalCode" {
  description = "The postal code of the site."
  type        = string
  default     = ""
}

variable "stateOrProvince" {
  description = "The state or province of the site."
  type        = string
  default     = ""
}

variable "streetAddress1" {
  description = "The first line of the street address of the site."
  type        = string
  default     = ""
}

variable "streetAddress2" {
  description = "The second line of the street address of the site."
  type        = string
  default     = ""
}

variable "streetAddress3" {
  description = "The third line of the street address of the site."
  type        = string
  default     = ""
}

variable "zipExtendedCode" {
  description = "The extended ZIP code of the site."
  type        = string
  default     = ""
}

variable "contactName" {
  description = "The contact name of the site."
  type        = string
  default     = " "
}

variable "emailList" {
  description = "A list of email addresses for the site."
  type        = list(string)
  default     = []
}

variable "mobile" {
  description = "The mobile phone number of the site."
  type        = string
  default     = ""
}

variable "phone" {
  description = "The phone number of the site."
  type        = string
  default     = ""
}

variable "phoneExtension" {
  description = "The phone extension of the site."
  type        = string
  default     = ""
}
