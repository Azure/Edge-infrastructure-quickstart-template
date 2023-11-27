/*
 * There is a bug currently with the LCM extension. It needs to wait 10-20 minutes to allow the servers to be ready before it can be deployed.
 */

resource "terraform_data" "waitServersReady" {
  depends_on = [module.servers]

  provisioner "local-exec" {
    command = "powershell -command sleep 1200"
  }
}

locals {
  storageAdapters  = flatten([for storageNetwork in var.storageNetworks : storageNetwork.networkAdapterName])
  combinedAdapters = setintersection(toset(var.managementAdapters), toset(local.storageAdapters))
  combined         = (length(local.combinedAdapters) == length(var.managementAdapters)) && (length(local.combinedAdapters) == length(local.storageAdapters))
  combinedIntents = [{
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
    overrideAdapterProperty = false,
    adapterPropertyOverrides = {
      jumboPacket             = "",
      networkDirectTechnology = "",
      networkDirect           = "Disabled"
    }
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
      adapterPropertyOverrides = {
        jumboPacket             = "",
        networkDirect           = "Disabled",
        networkDirectTechnology = ""
      }
  }]
}


resource "azapi_resource" "validatedeploymentsetting" {
  count                     = local.combined ? 1 : 0
  type                      = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2023-08-01-preview"
  name                      = "default"
  schema_validation_enabled = false
  parent_id                 = azapi_resource.cluster1.id
  depends_on = [
    terraform_data.waitServersReady,
    azurerm_key_vault_secret.arbDeploymentSpnName,
    azurerm_key_vault_secret.AzureStackLCMUserCredential,
    azurerm_key_vault_secret.LocalAdminCredential,
    azurerm_key_vault_secret.storageWitnessName,
    azapi_resource.cluster1
  ]
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  // ignore the deployment mode change after the first deployment
  ignore_body_changes = [
    "properties.deploymentMode"
  ]
  body = jsonencode({
    properties = {
      arcNodeResourceIds = flatten([for server in module.servers : server.server.id])
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
              domainFqdn   = "${var.domainFqdn}"
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
                intents                       = local.combinedIntents
                storageNetworks               = var.storageNetworks
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

resource "azapi_resource" "validatedeploymentsetting_seperate" {
  count                     = local.combined ? 0 : 1
  type                      = "Microsoft.AzureStackHCI/clusters/deploymentSettings@2023-08-01-preview"
  name                      = "default"
  schema_validation_enabled = false
  parent_id                 = azapi_resource.cluster1.id
  depends_on = [
    terraform_data.waitServersReady,
    azurerm_key_vault_secret.arbDeploymentSpnName,
    azurerm_key_vault_secret.AzureStackLCMUserCredential,
    azurerm_key_vault_secret.LocalAdminCredential,
    azurerm_key_vault_secret.storageWitnessName,
    azapi_resource.cluster1
  ]
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  // ignore the deployment mode change after the first deployment
  ignore_body_changes = [
    "properties.deploymentMode"
  ]
  body = jsonencode({
    properties = {
      arcNodeResourceIds = flatten([for server in module.servers : server.server.id])
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
              domainFqdn   = "${var.domainFqdn}"
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
                intents                       = local.seperateIntents
                storageNetworks               = var.storageNetworks
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
