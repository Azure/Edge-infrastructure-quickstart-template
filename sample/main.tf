# module "hci" {
#   source                = "../module"
#   location              = "eastus"
#   siteId                = "<siteId>"
#   domainName            = "<domainName>"
#   domainAdminUser       = "<DomainAdminUserName>"
#   domainAdminPassword   = "<DomainAdminPassword>"
#   localAdminUser        = "<LocalAdminUserName>"
#   localAdminPassword    = "<DomainAdminPassword>"
#   arbDeploymentSpnValue = "<arbSpnId>:<arbSpnSecret>"
#   domainSuffix          = "<domainSuffix>"
#   startingAddress       = "<infrastrucutreNetworkStartingAddress>"
#   endingAddress         = "<infrastrucutreNetworkEndingAddress>"
#   defaultGateway        = "<infrastrucutreNetworkDefaultGateway>"
#   dnsServers            = ["<dnsServer>"]
#   adouPath              = "<adouPath>"
#   subId                 = "<subscriptionId>"
#   tenant                = "<tenantId>"
#   servicePricipalId     = "<servicePricipalId>"
#   servicePricipalSecret = "<servicePricipalSecret>"
#   servers = [
#     {
#       name        = "<server1Name>",
#       ipv4Address = "<server1IP>"
#     },
#     {
#       name        = "<server2Name>",
#       ipv4Address = "<server2IP>"
#     }
#   ]
# }
