data "azurerm_arc_machine" "arcservers" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  name                = each.key
  resource_group_name = var.resourceGroup.name
}

locals {
  storageAdapters  = flatten([for storageNetwork in var.storageNetworks : storageNetwork.networkAdapterName])
  combinedAdapters = setintersection(toset(var.managementAdapters), toset(local.storageAdapters))
  converged        = (length(local.combinedAdapters) == length(var.managementAdapters)) && (length(local.combinedAdapters) == length(local.storageAdapters))

  adapterProperties = {
    jumboPacket             = ""
    networkDirect           = "Disabled"
    networkDirectTechnology = ""
  }
  rdmaAdapterProperties = {
    jumboPacket             = "9014"
    networkDirect           = "Enabled"
    networkDirectTechnology = "RoCEv2"
  }

  switchlessAdapterProperties = {
    jumboPacket             = "9014"
    networkDirect           = "Enabled"
    networkDirectTechnology = "iWARP"
  }

  convergedIntents = [{
    name = "ManagementComputeStorage",
    trafficType = [
      "Management",
      "Compute",
      "Storage"
    ],
    adapter                            = var.managementAdapters,
    overrideVirtualSwitchConfiguration = false,
    virtualSwitchConfigurationOverrides = {
      enableIov              = "",
      loadBalancingAlgorithm = ""
    },
    overrideQosPolicy = false,
    qosPolicyOverrides = {
      priorityValue8021Action_SMB     = "",
      priorityValue8021Action_Cluster = "",
      bandwidthPercentage_SMB         = ""
    },
    overrideAdapterProperty  = false,
    adapterPropertyOverrides = var.rdmaEnabled ? local.rdmaAdapterProperties : local.adapterProperties
  }]

  seperateIntents = [{
    name = "ManagementCompute",
    trafficType = [
      "Management",
      "Compute"
    ],
    adapter                            = var.managementAdapters
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
      adapter                            = local.storageAdapters,
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
      adapterPropertyOverrides = var.rdmaEnabled ? (var.storageConnectivitySwitchless ? local.switchlessAdapterProperties : local.rdmaAdapterProperties) : local.adapterProperties
  }]
}


resource "azapi_resource" "validatedeploymentsetting" {
  count                     = local.converged ? 1 : 0
  type                      = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2023-08-01-preview"
  name                      = "default"
  schema_validation_enabled = false
  parent_id                 = azapi_resource.cluster.id
  depends_on = [
    azurerm_key_vault_secret.DefaultARBApplication,
    azurerm_key_vault_secret.AzureStackLCMUserCredential,
    azurerm_key_vault_secret.LocalAdminCredential,
    azurerm_key_vault_secret.WitnessStorageKey,
    azapi_resource.cluster,
    module.serverRoleBindings,
    azurerm_role_assignment.ServicePrincipalRoleAssign,
  ]
  timeouts {}
  // ignore the deployment mode change after the first deployment
  ignore_body_changes = [
    "properties.deploymentMode"
  ]
  body = jsonencode({
    properties = {
      arcNodeResourceIds = flatten([for server in data.azurerm_arc_machine.arcservers : server.id])
      deploymentMode     = var.isExported ? "Deploy" : "Validate"
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
                name                 = azapi_resource.cluster.name
                witnessType          = "Cloud"
                witnessPath          = "Cloud"
                cloudAccountName     = azurerm_storage_account.witness.name
                azureServiceEndpoint = "core.windows.net"
              }
              storage = {
                configurationMode = "Express" //
              }
              namingPrefix = var.siteId
              domainFqdn   = "${var.domainFqdn}"
              infrastructureNetwork = [{
                useDhcp    = false
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
                enableStorageAutoIp           = true
                intents                       = local.convergedIntents
                storageNetworks               = var.storageNetworks
                storageConnectivitySwitchless = false
              }
              adouPath        = var.adouPath
              secretsLocation = azurerm_key_vault.DeploymentKeyVault.vault_uri
              optionalServices = {
                customLocation = var.customLocationName
              }

            }
          }
        ]
      }
    }
  })
}

resource "azapi_resource" "validatedeploymentsetting_seperate" {
  count                     = local.converged ? 0 : 1
  type                      = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2023-08-01-preview"
  name                      = "default"
  schema_validation_enabled = false
  parent_id                 = azapi_resource.cluster.id
  depends_on = [
    azurerm_key_vault_secret.DefaultARBApplication,
    azurerm_key_vault_secret.AzureStackLCMUserCredential,
    azurerm_key_vault_secret.LocalAdminCredential,
    azurerm_key_vault_secret.WitnessStorageKey,
    azapi_resource.cluster
  ]
  timeouts {}
  // ignore the deployment mode change after the first deployment
  ignore_body_changes = [
    "properties.deploymentMode"
  ]
  body = jsonencode({
    properties = {
      arcNodeResourceIds = flatten([for server in data.azurerm_arc_machine.arcservers : server.id])
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
                name                 = azapi_resource.cluster.name
                witnessType          = "Cloud"
                witnessPath          = "Cloud"
                cloudAccountName     = azurerm_storage_account.witness.name
                azureServiceEndpoint = "core.windows.net"
              }
              storage = {
                configurationMode = "Express" //
              }
              namingPrefix = var.siteId
              domainFqdn   = "${var.domainFqdn}"
              infrastructureNetwork = [{
                useDhcp    = false
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
                enableStorageAutoIp           = true
                intents                       = local.seperateIntents
                storageNetworks               = var.storageNetworks
                storageConnectivitySwitchless = false
              }
              adouPath        = var.adouPath
              secretsLocation = azurerm_key_vault.DeploymentKeyVault.vault_uri
              optionalServices = {
                customLocation = var.customLocationName
              }
            }
          }
        ]
      }
    }
  })
}
