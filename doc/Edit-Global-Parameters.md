# Edit Global Parameters
  
You may edit `modules/base` to customize your deployment template for all sites. You may add default values for your sites in `modules/base/variables.*.tf`.

Variables are grouped by products. For example, HCI related variables are defined in `modules/base/variables.hci.tf`. You can go to the corresponding file for the product you want to modify its configurations.

For each file, there are several sections. The first section is `Global variables`. You can add default values to avoid repeating the configuration for each site. For example, if you want to set the global parameter of your AD FQDN, you can go to `modules/base/variables.hci.tf` and add a default attribute. (Do not add the starting `+`.)

```hcl
  variable "domainFqdn" {
    description = "The domain FQDN."
    type        = string
+   default     = "stores.contoso.com"
  }
```

## Folding sections in VS Code

Press `F1`, open `Preferences: Open User Settings`. Search `folding`, change `Folding Strategy` from `auto` to `indentation`.
