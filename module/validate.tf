resource "azapi_resource" "validatedeploymentsetting" {
  type                      = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2023-08-01-preview"
  name                      = "default"
  schema_validation_enabled = false
  parent_id                 = azapi_resource.cluster1.id
  depends_on                = [module.server-1, module.server-2, azurerm_key_vault_secret.arbDeploymentSpnName, azurerm_key_vault_secret.arbDeploymentSpnName, azurerm_key_vault_secret.AzureStackLCMUserCredential, azurerm_key_vault_secret.LocalAdminCredential, azurerm_key_vault_secret.storageWitnessName]
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  body = jsonencode({
    properties = {
      arcNodeResourceIds = [module.server-1.server.id, module.server-2.server.id]
      deploymentMode     = "Validate" //Deploy
      deploymentConfiguration = {
        version = "10.0.0.0"
        scaleUnits = [
          {
            deploymentData = {
              securitySettings = {
                hvciProtection                = true
                drtmProtection                = true
                driftControlEnforced          = true
                credentialGuardEnforced       = true
                smbSigningEnforced            = true
                smbClusterEncryption          = false
                sideChannelMitigationEnforced = true
                bitlockerBootVolume           = true
                bitlockerDataVolumes          = true
                wdacEnforced                  = true
              }
              observability = {
                streamingDataClient = true
                euLocation          = false
                episodicDataUpload  = true
              }
              cluster = {
                name                 = azapi_resource.cluster1.name
                witnessType          = "Cloud"
                witnessPath          = "Cloud"
                cloudAccountName     = azurerm_storage_account.witness.name
                azureServiceEndpoint = "core.windows.net"
              }
              storage = {
                configurationMode = "Express" //
              }
              namingPrefix = var.siteId
              domainFqdn   = "${var.siteId}.${var.domainSuffix}"
              infrastructureNetwork = [{
                subnetMask = var.subnetMask
                gateway    = var.defaultGateway
                ipPools = [
                  {
                    startingAddress = var.startingAddress
                    endingAddress   = var.endingAddress
                  }
                ]
                dnsServers = var.dnsServers
              }]
              physicalNodes = var.servers
              hostNetwork = {
                intents = [
                  {
                    name = "ManagementCompute",
                    trafficType = [
                      "Management",
                      "Compute"
                    ],
                    adapter = [
                      "ethernet",
                      "ethernet 2"
                    ],
                    overrideVirtualSwitchConfiguration = false,
                    overrideQosPolicy                  = false,
                    overrideAdapterProperty            = false,
                    virtualSwitchConfigurationOverrides = {
                      enableIov              = "",
                      loadBalancingAlgorithm = ""
                    },
                    qosPolicyOverrides = {
                      priorityValue8021Action_Cluster = "",
                      priorityValue8021Action_SMB     = "",
                      bandwidthPercentage_SMB         = ""
                    },
                    adapterPropertyOverrides = {
                      jumboPacket             = "",
                      networkDirect           = "Disabled",
                      networkDirectTechnology = ""
                    }
                  },
                  {
                    name = "Storage",
                    trafficType = [
                      "Storage"
                    ],
                    adapter = [
                      "ethernet 3",
                      "ethernet 4"
                    ],
                    overrideVirtualSwitchConfiguration = false,
                    overrideQosPolicy                  = false,
                    overrideAdapterProperty            = false,
                    virtualSwitchConfigurationOverrides = {
                      enableIov              = "",
                      loadBalancingAlgorithm = ""
                    },
                    qosPolicyOverrides = {
                      priorityValue8021Action_Cluster = "",
                      priorityValue8021Action_SMB     = "",
                      bandwidthPercentage_SMB         = ""
                    },
                    adapterPropertyOverrides = {
                      jumboPacket             = "",
                      networkDirect           = "Disabled",
                      networkDirectTechnology = ""
                    }
                  }
                ]
                storageNetworks = [
                  {
                    name               = "Storage1Network",
                    networkAdapterName = "ethernet 3",
                    vlanId             = "711"
                  },
                  {
                    name               = "Storage2Network",
                    networkAdapterName = "ethernet 4",
                    vlanId             = "712"
                  }
                ]
                storageConnectivitySwitchless = false
              }
              adouPath        = var.adouPath
              secretsLocation = azurerm_key_vault.DeploymentKeyVault.vault_uri
              optionalServices = {
                customLocation = "${var.siteId}-customLocation"
              }

            }
          }
        ]
      }
    }
  })
}
