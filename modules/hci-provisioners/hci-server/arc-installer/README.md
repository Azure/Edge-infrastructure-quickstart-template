# Steps Involved to invoke Cloud Deployment in a headless way without Portal
1. [Setup your subscription for Private Preview Access to use CloudBased Deployment feature](#setup-your-subscription-for-private-preview-access-to-use-cloudbased-deployment-feature)
2. [Enable ARC on the nodes and install mandatory extensions (Ignore this step if you are using a ZTB supported OS)](#enable-arc-on-the-nodes-and-install-mandatory-extensions-(ignore-this-step-if-you-are-using-a-ztb-supported-os))
3. [Trigger Environment validator and Deployment on the node](#trigger-environment-validator-and-deployment-on-the-node)


# Setup your subscription for Private Preview Access to use CloudBased Deployment feature
* Cloud based deployment is currently live only in CentralUSEUAP region
* You will need to enable the following feature flags on your subscription to enable Cloudbased Deployment (this can be done via ACIS actions on a SAW):
   Flag   | ProviderName
   -----  | -------------
   PreviewRegions | Microsoft.HybridCompute
   HybridRPCanary | Microsoft.HybridCompute
   HiddenPreviewAccess | Microsoft.AzurestackHCI
   EUAPParticipation  | Microsoft.Resources 


# Enable ARC on the nodes and install mandatory extensions (Ignore this step if you are using a ZTB supported OS)
## How to run ARC Installer on a HCI Node:
* A custom role by the name Azure Stack HCI Edge Devices role must be created beforehand for the arc installer to work
* The permissions should be :
  "permissions": [
    {
      "actions": [
        "Microsoft.AzureStackHCI/EdgeDevices/Read",
        "Microsoft.AzureStackHCI/EdgeDevices/Write",
        "Microsoft.AzureStackHCI/EdgeDevices/Delete",
        "Microsoft.AzureStackHCI/EdgeDevices/Validate/Action"
      ],
      "notActions": [],
      "dataActions": [],
      "notDataActions": []
    }
  ]
* Download the "AzSHCI-cloud-deploy-tools\src\arc-installer" to a HCI node
* cd arc-installer
* Import-Module  .\AzSHCI.ARCInstaller.psm1 -Force
* install-module Az.Accounts -Force
* install-module Az.ConnectedMachine -Force
* install-module Az.Resources -Force
* $subscriptionID = ""
* $tenantID = ""
* $resourceGroup = ""
   * *Resource group needs to be pre-created* 
* Connect-AzAccount -SubscriptionId $subscriptionID -TenantId $tenantID -DeviceCode
  * e.g. Connect-AzAccount -SubscriptionId $subscriptionID -TenantId $tenantID -DeviceCode
* $armToken = (Get-AzAccessToken).Token 
* $id = (Get-AzContext).Account.Id
* Invoke-AzStackHciArcInitialization -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -Region centraluseuap -Cloud "AzureCloud" -ArmAccessToken $armToken   -AccountID $id 
  * **Cloud based deployment is currently live only in CentralUSEUAP and EastUSEUAP regions**




## Cleanup ARC Agentry HCI Node
* Download the "AzSHCI-cloud-deploy-tools\src\arc-installer" to a HCI node
* cd arc-installer
* Import-Module  .\AzSHCI.ARCInstaller.psm1 -Force
* install-module Az.Accounts -Force
* install-module Az.ConnectedMachine -Force
* $subscriptionID = ""
* $tenantID = ""
* Connect-AzAccount -SubscriptionId $subscriptionID -TenantId $tenantID
    e.g. Connect-AzAccount -SubscriptionId $subscriptionID -TenantId $tenantID
* $armToken = (Get-AzAccessToken).Token 
* $id = (Get-AzContext).Account.Id
* Remove-AzStackHciArcInitialization -SubscriptionID $subscriptionID -ResourceGroup "20H2HSC1-rg" -TenantID $tenantID -Cloud "AzureCloud" -ArmAccessToken $armToken   -AccountID $id


## Installing PS Module
Incase, you want to try installing the AzSHCI.ARCInstaller powershell module:

* Download the Powershell module from the pipeline artefacts.
* Mkdir ~/myPSRepo
* Copy the downloaded PS module to ~/myPSRepo
* Register-PSRepository -Name "arcin" -SourceLocation ~/myPSRepo
* Install-module AzSHCI.ARCInstaller -Repository arcin

# Trigger Environment validator and Deployment on the node

## Pre-requisites

* Make sure that the nodes are arc enabled and mandatory extensions are installed.
* Download the "AzSHCI-cloud-deploy-tools\src\arc-installer" to a HCI node
* This script needs to be run with administrator privileges and above
* cd arc-installer
* Import-Module  .\AzSHCI.CloudDeploymentTool.psm1 -Force
* install-module Az.Accounts -Force
* install-module Az.Resources -Force

## Parameters
* $subscriptionID = "" *(The subscription id in which the cluster needs to be deployed)*
* $tenantID = "" *(The tenant id in which the cluster needs to be deployed)*
* $resourceGroup = "" *(The resource Group in which the cluster needs to be deployed)*
* $clusterName = "" *(The name of the cluster). It is an optional parameter, if not provided will be picked up from the answer file*
* $answerFilePath = "" 
    * *The path of the answer file already pre-created for CI or cmdline deployments*
* $arcNodeIds = @() 
    * The resource id of the ARC machines in the same resource group. The Arc machines should be present in the same resource group as the cluster*
    * E.g. @(/subscriptions/680d0dad-59aa-4464-adf3-b34b2b427e8c/resourceGroups/nir-test-rg/providers/Microsoft.HybridCompute/machines/nir191)
* $LocalAdminUserName = ''
* $LocalAdminUserPass = ''
* $LocalAdminSecureString = ConvertTo-SecureString -AsPlainText $LocalAdminUserPass -Force
* $LocalAdminUserCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($LocalAdminUserName,$LocalAdminSecureString) 
    * *Create the credentials for the local admin credentials*
* $DomainAdminUserName = ''
* $DomainAdminUserPass = ''
* $DomainAdminSecureString = ConvertTo-SecureString -AsPlainText $DomainAdminUserPass -Force
* $DomainAdminUserCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($DomainAdminUserName,$DomainAdminSecureString) 
    *  *Create the credentials for the domain admin credentials*
* $Prefix = '' *(The prefix or the unique identifier that could be passed to the methods to uniquely identify a storage account or a key vault)*

## Run the Environment Preparation cmdlet
* Run Connect-AzAccount with User Credentials or Service Principal Credentials
* For User Credentials - Connect-AzAccount -SubscriptionID $subscriptionID -TenantID $tenantID -Credentials $Credential
* For spn - Connect-AzAccount --ServicePrincipal -TenantID $tenantID -Credentials $Credential
    * *$Credential - This could be the registration user credentials or the SPN credentials*
    * *When the authentication is done using spn, an AAD app has to be created first and then the spn created should have User.ReadWrite.All permissions because it will be used for creating another SPN during deployment*
* Run the environment preparator to create the key vault (with the secrets) and the storage account and the SPN and assign the permissions
* Invoke-AzStackHCIEnvironmentPreparator -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -Region centraluseuap -Cloud "AzureCloud" -LocalAdminCredentials $LocalAdminUserCreds -DomainAdminCredentials $DomainAdminUserCreds -ClusterName $clusterName -ArcNodeIds $arcNodeIds -Prefix $Prefix

## Run the Enviroment validator cmdlet
* Run the environment validator to trigger Environment Validation
* Run Connect-AzAccount with User Credentials or Service Principal
* For User Credentials - Connect-AzAccount -SubscriptionID $subscriptionID -TenantID $tenantID -Credentials $Credential
* For spn - Connect-AzAccount --ServicePrincipal -TenantID $tenantID -Credentials $Credential
    * *$Credential - This could be the registration user credentials or the SPN credentials*
    * *When the authentication is done using spn, an AAD app has to be created first and then the spn created should have User.ReadWrite.All permissions because it will be used for creating another SPN during deployment*
* Invoke-AzStackHCIEnvironmentValidator -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -ClusterName $clusterName -AnswerFilePath $answerFilePath -ArcNodeIds $arcNodeIds -Prefix $Prefix
* This will trigger the environment validator and we can continuously poll for the status of the validation by running this command
* PollDeploymentSettingsStatus -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -ClusterName $clusterName
* Run the environment deployment command to trigger a deployment once the validation succeeds

## Run the deployment cmdlet once validation completes successfully
* Run Connect-AzAccount with User Credentials or Service Principal
* For User Credentials - Connect-AzAccount -SubscriptionID $subscriptionID -TenantID $tenantID -Credentials $Credential
* For spn - Connect-AzAccount --ServicePrincipal -TenantID $tenantID -Credentials $Credential
    * *$Credential - This could be the registration user credentials or the SPN credentials*
    * *When the authentication is done using spn, an AAD app has to be created first and then the spn created should have User.ReadWrite.All permissions because it will be used for creating another SPN during deployment*
* Invoke-AzStackHCIDeployment -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -ClusterName $clusterName -AnswerFilePath $answerFilePath -ArcNodeIds $arcNodeIds -Prefix $Prefix
* This will trigger the environment deployment and we can continuously poll for the status of the deployment by running this command
* PollDeploymentSettingsStatus -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -ClusterName $clusterName

## Trigger Full Deployment by combining the above 3 steps (optional)
* Run Connect-AzAccount with Credentials or Service Principal
* For user credentials - Connect-AzAccount -SubscriptionID $subscriptionID -TenantID $tenantID -Credentials $Credential
* For spn - Connect-AzAccount --ServicePrincipal -TenantID $tenantID -Credentials $Credential
    * *$Credential - This could be the registration user credentials or the SPN credentials*
    * *When the authentication is done using spn, an AAD app has to be created first and then the spn created should have User.ReadWrite.All permissions because it will be used for creating another SPN during deployment*
* Additionally there is a command which triggers the full deployment (preparation + environment validation + environment deployment). This will also validate that the environment validation has succeeded and then move forward for deployment and check deployment status
* Invoke-AzStackHCIFullDeployment -SubscriptionID $subscriptionID -ResourceGroup $resourceGroup -TenantID $tenantID -Region centraluseuap -Cloud "AzureCloud" -LocalAdminCredentials $LocalAdminUserCreds -DomainAdminCredentials $DomainAdminUserCreds -ClusterName $clusterName -AnswerFilePath $answerFilePath -ArcNodeIds $arcNodeIds -Prefix $Prefix