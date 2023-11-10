# module "hci" {  
#   source                = "../module"  
#   location              = "eastus"  
#   siteId                = "<SiteId>"  
#   domainName            = "<DomainName>"  
#   domainAdminUser       = "<DomainAdminUserName>"  
#   domainAdminPassword   = "<DomainAdminPassword>"  
#   localAdminUser        = "<LocalAdminUserName>"  
#   localAdminPassword    = "<LocalAdminPassword>"  
#   arbDeploymentSpnValue = "<ArbSpnId>:<ArbSpnSecret>"  
#   domainSuffix          = "<DomainSuffix>"  
#   startingAddress       = "<InfrastructureNetworkStartingAddress>"  
#   endingAddress         = "<InfrastructureNetworkEndingAddress>"  
#   defaultGateway        = "<InfrastructureNetworkDefaultGateway>"  
#   dnsServers            = ["<DnsServer>"]  
#   adouPath              = "<AdouPath>"  
#   subId                 = "<SubscriptionId>"  
#   tenant                = "<TenantId>"  
#   servicePricipalId     = "<ServicePrincipalId>"  
#   servicePricipalSecret = "<ServicePrincipalSecret>"  
#   servers = [  
#     {  
#       name        = "<Server1Name>",  
#       ipv4Address = "<Server1IP>"  
#     },  
#     {  
#       name        = "<Server2Name>",  
#       ipv4Address = "<Server2IP>"  
#     }  
#   ]  
# }  
