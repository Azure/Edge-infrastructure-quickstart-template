# Potential global variables
  variable "location" {
    type        = string
    description = "The Azure region where the resources will be deployed."

    validation {
      condition     = can(regex("^(australiacentral|australiacentral2|australiaeast|australiasoutheast|brazilsouth|brazilsoutheast|brazilus|canadacentral|canadaeast|centralindia|centralus|centraluseuap|eastasia|eastus|eastus2|eastus2euap|francecentral|francesouth|germanynorth|germanywestcentral|israelcentral|italynorth|japaneast|japanwest|jioindiacentral|jioindiawest|koreacentral|koreasouth|malaysiasouth|mexicocentral|northcentralus|northeurope|norwayeast|norwaywest|polandcentral|qatarcentral|southafricanorth|southafricawest|southcentralus|southeastasia|southindia|spaincentral|swedencentral|swedensouth|switzerlandnorth|switzerlandwest|uaecentral|uaenorth|uksouth|ukwest|westcentralus|westeurope|westindia|westus|westus2|westus3|austriaeast|chilecentral|eastusslv|israelnorthwest|malaysiawest|newzealandnorth|northeuropefoundational|taiwannorth|taiwannorthwest)$", var.location))
      error_message = "supported Azure Locations:australiacentral,australiacentral2,australiaeast,australiasoutheast,brazilsouth,brazilsoutheast,brazilus,canadacentral,canadaeast,centralindia,centralus,centraluseuap,eastasia,eastus,eastus2,eastus2euap,francecentral,francesouth,germanynorth,germanywestcentral,israelcentral,italynorth,japaneast,japanwest,jioindiacentral,jioindiawest,koreacentral,koreasouth,malaysiasouth,mexicocentral,northcentralus,northeurope,norwayeast,norwaywest,polandcentral,qatarcentral,southafricanorth,southafricawest,southcentralus,southeastasia,southindia,spaincentral,swedencentral,swedensouth,switzerlandnorth,switzerlandwest,uaecentral,uaenorth,uksouth,ukwest,westcentralus,westeurope,westindia,westus,westus2,westus3,austriaeast,chilecentral,eastusslv,israelnorthwest,malaysiawest,newzealandnorth,northeuropefoundational,taiwannorth,taiwannorthwest"
    }
  }

# Site specific variables
  variable "siteId" {
    type        = string
    description = "A unique identifier for the site."
  }

# Pass through variables
  variable "subscriptionId" {
    type        = string
    description = "The subscription ID for resources."
  }
