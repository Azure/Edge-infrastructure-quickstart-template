resource "azapi_resource" "connectedCluster" {
  type = "Microsoft.Kubernetes/connectedClusters@2024-01-01"
  depends_on = [
    azapi_resource.logicalNetwork,
    data.azapi_resource.logicalNetwork,
    azurerm_key_vault_secret.sshPublicKey,
    azurerm_key_vault_secret.sshPrivateKeyPem,
    terraform_data.waitAksVhdReady,
  ]
  name      = var.aksArcName
  parent_id = var.resourceGroup.id

  payload = {
    kind = "ProvisionedCluster"
    properties = {
      aadProfile = {
        adminGroupObjectIDs = var.rbacAdminGroupObjectIds
        enableAzureRBAC     = var.enableAzureRBAC
        tenantID            = var.azureRBACTenantId
      }
      agentPublicKeyCertificate = "" //agentPublicKeyCertificate input must be empty for Connected Cluster of Kind: Provisioned Cluster
      azureHybridBenefit        = null
      distribution              = null
      infrastructure            = null
      privateLinkState          = null
      provisioningState         = null
    }
  }

  identity {
    type = "SystemAssigned"
  }

  location = var.resourceGroup.location

  lifecycle {
    ignore_changes = [
      identity[0],
      payload.properties.azureHybridBenefit,
      payload.properties.distribution,
      payload.properties.infrastructure,
      payload.properties.privateLinkState,
      payload.properties.provisioningState,
    ]
  }

  # timeouts {}
}
locals {
  agentPoolProfiles = [for pool in var.agentPoolProfiles : {
    for k, v in pool : k => v if v != null
  }]
}

resource "azapi_resource" "provisionedClusterInstance" {
  type       = "Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01"
  depends_on = [azapi_resource.connectedCluster]
  parent_id  = azapi_resource.connectedCluster.id
  name       = "default"
  payload = {
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      agentPoolProfiles = local.agentPoolProfiles
      autoScalerProfile = null
      cloudProviderProfile = {
        infraNetworkProfile = {
          vnetSubnetIds = [
            local.logicalNetworkId,
          ]
        }
      }
      controlPlane = {
        count  = var.controlPlaneCount
        vmSize = var.controlPlaneVmSize
        controlPlaneEndpoint = {
          hostIP = var.controlPlaneIp
        }
      }
      kubernetesVersion = var.kubernetesVersion
      linuxProfile = {
        ssh = {
          publicKeys = [
            {
              keyData = local.sshPublicKey
            },
          ]
        }
      }
      networkProfile = {
        podCidr       = var.podCidr
        networkPolicy = "calico"
        loadBalancerProfile = {
          // acctest0002 network only supports a LoadBalancer count of 0
        }
      }
      storageProfile = {
        smbCsiDriver = {
          enabled = true
        }
        nfsCsiDriver = {
          enabled = true
        }
      }
      clusterVMAccessProfile = {}
      licenseProfile         = { azureHybridBenefit = "False" }
    }
  }

  lifecycle {
    ignore_changes = [
      payload.properties.autoScalerProfile,
      payload.properties.networkProfile.podCidr,
      payload.properties.provisioningStateTransitionTime,
      payload.properties.provisioningStateUpdatedTime,
    ]
  }
  # timeouts {}
}
