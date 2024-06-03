data "azurerm_client_config" "current" {}

resource "azapi_resource" "connectedCluster" {
  type = "Microsoft.Kubernetes/connectedClusters@2024-01-01"
  depends_on = [
    azurerm_key_vault_secret.sshPublicKey,
    azurerm_key_vault_secret.sshPrivateKeyPem,
    terraform_data.waitAksVhdReady,
  ]
  name      = var.aksArcName
  parent_id = var.resourceGroup.id

  body = {
    kind = "ProvisionedCluster"
    properties = {
      aadProfile = {
        adminGroupObjectIDs = flatten(var.rbacAdminGroupObjectIds)
        enableAzureRBAC     = var.enableAzureRBAC
        tenantID            = data.azurerm_client_config.current.tenant_id
      }
      agentPublicKeyCertificate = "" //agentPublicKeyCertificate input must be empty for Connected Cluster of Kind: Provisioned Cluster
      azureHybridBenefit        = null
      privateLinkState          = null
      provisioningState         = null
      infrastructure            = null
      distribution              = null
    }
  }

  identity {
    type = "SystemAssigned"
  }

  location = var.resourceGroup.location

  lifecycle {
    ignore_changes = [
      identity[0],
      body.properties.azureHybridBenefit,
      body.properties.distribution,
      body.properties.infrastructure,
      body.properties.privateLinkState,
      body.properties.provisioningState,
    ]
  }
}
locals {
  agentPoolProfiles = [for pool in var.agentPoolProfiles : {
    for k, v in pool : k => (k == "nodeTaints" ? flatten(v) : v) if v != null
  }]
}

resource "azapi_resource" "provisionedClusterInstance" {
  type       = "Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01"
  depends_on = [azapi_resource.connectedCluster]
  parent_id  = azapi_resource.connectedCluster.id
  name       = "default"
  body = {
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      agentPoolProfiles = flatten(local.agentPoolProfiles)
      cloudProviderProfile = {
        infraNetworkProfile = {
          vnetSubnetIds = [
            var.logicalNetworkId,
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
      body.properties.autoScalerProfile,
      body.properties.networkProfile.podCidr,
      body.properties.provisioningStateTransitionTime,
      body.properties.provisioningStateUpdatedTime,
    ]
  }
}
