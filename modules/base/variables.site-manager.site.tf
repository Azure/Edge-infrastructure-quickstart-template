variable "city" {
  description = "The city of the site."
  type        = string
  default     = ""
}

variable "company_name" {
  description = "The company name of the site."
  type        = string
  default     = ""
}

variable "postal_code" {
  description = "The postal code of the site."
  type        = string
  default     = ""
}

variable "state_or_province" {
  description = "The state or province of the site."
  type        = string
  default     = ""
}

variable "street_address_1" {
  description = "The first line of the street address of the site."
  type        = string
  default     = ""
}

variable "street_address_2" {
  description = "The second line of the street address of the site."
  type        = string
  default     = ""
}

variable "street_address_3" {
  description = "The third line of the street address of the site."
  type        = string
  default     = ""
}

variable "zip_extended_code" {
  description = "The extended ZIP code of the site."
  type        = string
  default     = ""
}

variable "contact_name" {
  description = "The contact name of the site."
  type        = string
  default     = " "
}

variable "email_list" {
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

variable "phone_extension" {
  description = "The phone extension of the site."
  type        = string
  default     = ""
}
