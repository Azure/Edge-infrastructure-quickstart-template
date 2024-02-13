# Edit Global Parameters
  
You may edit `modules/base` to customize your deployment template for all sites. You may add default values for your sites in `modules/base/variables.*.tf`.

Variables are grouped by products. For example, HCI related variables are defined in `modules/base/variables.hci.tf`. You can go to the corresponding file for the product you want to modify its configurations.

For each file, there are several sections. The first section is `Potential global variables`. You can add default values to avoid repeating the configuration for each site. For example, if you want to set the global parameter of your AD FQDN, you can go to `modules/base/variables.hci.tf` and add a default attribute. (Do not add the starting `+`.)
```hcl
  variable "domainFqdn" {
    description = "The domain FQDN."
    type        = string
+   default     = "stores.contoso.com"
  }
```

The second section is `Site specific variables`. These variables must be defined in the site `main.tf` file. If you feel some of them is globally shared, you can move the variable to global variables section.

The third section is `Pass through variables`. These variables are typically defined in the repo secrets. They are passed to underlying modules by these pass through variables.

The forth section is `Reference variables`. These variables are shared by 2 or more products. They will have a reference link in one product. Its definition can be found in `variables.<product>.tf` if its link is `ref/<production>/<variable_name>`.

## Folding sections in VS Code

Press `F1`, open `Preferences: Open User Settings`. Search `folding`, change `Folding Strategy` from `auto` to `indentation`.
