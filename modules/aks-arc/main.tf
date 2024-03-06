resource "azapi_resource" "connectedCluster" {
  type = "Microsoft.Kubernetes/connectedClusters@2023-11-01-preview"
  depends_on = [
    azapi_resource.logicalNetwork,
    data.azapi_resource.logicalNetwork,
    azurerm_key_vault_secret.sshPublicKey,
    azurerm_key_vault_secret.sshPrivateKeyPem,
    terraform_data.waitAksVhdReady,
  ]
  name      = var.aksArcName
  parent_id = var.resourceGroup.id

  body = jsonencode({
    kind = "ProvisionedCluster"
    identity = {
      type = "SystemAssigned"
    }
    location = var.resourceGroup.location
    properties = {
      aadProfile = {
        adminGroupObjectIDs = var.rbacAdminGroupObjectIds
        enableAzureRBAC     = var.enableAzureRBAC
        tenantID            = var.azureRBACTenantId
      }
      agentPublicKeyCertificate = "" //agentPublicKeyCertificate input must be empty for Connected Cluster of Kind: Provisioned Cluster
    }
  })

  timeouts {}
}


resource "azapi_resource" "provisionedClusterInstance" {
  type       = "Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01"
  depends_on = [azapi_resource.connectedCluster]
  parent_id  = azapi_resource.connectedCluster.id
  name       = "default"
  body = jsonencode({
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      agentPoolProfiles = var.agentPoolProfiles
      cloudProviderProfile = {
        infraNetworkProfile = {
          vnetSubnetIds = [
            local.logicalNetworkId,
          ]
        }
      }
      controlPlane = {
        count = var.controlPlaneCount
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
  })
  schema_validation_enabled = false
  ignore_casing             = false
  ignore_missing_property   = false
  timeouts {}
}
