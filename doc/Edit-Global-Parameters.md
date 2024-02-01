# Edit Global Parameters
  
You may edit `modules/base` to customize your deployment template for all sites. You may add default values for your sites in `modules/base/variables.tf`. For example, tenant name is likely to be the same for all sites. You can add a default value for `tenant` variable.
```hcl
variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
  default     = "<your tennat ID>"
}
```
