# # Uncomment the following lines to import the resource group when Arc servers are provisioned by yourself.

 import {
   id = "/subscriptions/fbaf508b-cb61-4383-9cda-a42bfa0c7bc9/resourceGroups/California"
   to = module.base.azurerm_resource_group.rg
 }
