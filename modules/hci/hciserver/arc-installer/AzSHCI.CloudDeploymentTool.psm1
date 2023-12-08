<#############################################################
 #                                                           #
 # Copyright (C) Microsoft Corporation. All rights reserved. #
 #                                                           #
 #############################################################>
Import-Module $PSScriptRoot\Classes\reporting.psm1 -Force -DisableNameChecking -Global

function Invoke-AzStackHCIEnvironmentPreparator {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,
          
        # AzureCloud , AzureUSGovernment , AzureChinaCloud 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Cloud type used for HCI Cluster Deployment. Valid values are : AzureCloud , AzureUSGovernment , AzureChinaCloud")]
        [string] 
        $Cloud,
        
        [Parameter(Mandatory = $true, HelpMessage = "Azure Region used for HCI Cluster Deployment")]
        [string] 
        $Region,
 
        [Parameter(Mandatory = $false, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName,
 
        [Parameter(Mandatory = $true, HelpMessage = "Local Admin Credentials Required for deployment")]
        [System.Management.Automation.PSCredential]
        $LocalAdminCredentials,
         
        [Parameter(Mandatory = $true, HelpMessage = "Cloud Admin Credentials Required for deployment")]
        [System.Management.Automation.PSCredential] 
        $DomainAdminCredentials,
 
        [Parameter(Mandatory = $true, HelpMessage = "Arc Node ids required for cloud based deployment")]
        [string[]] 
        $ArcNodeIds,
 
        [Parameter(Mandatory = $false, HelpMessage = "Return PSObject result.")]
        [System.Collections.Hashtable] $Tag,
 
        [Parameter(Mandatory = $false, HelpMessage = "Directory path for log and report output")]
        [string]$OutputPath,
 
        [Parameter(Mandatory = $false)]
        [Switch] $Force,

        [Parameter(Mandatory = $false, HelpMessage = "Prefix to uniquely identify a storage account and a keyvault")]
        [string] $Prefix
    )
    try {
        $script:ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        $DebugPreference = "Continue"
        Set-AzStackHciOutputPath -Path $OutputPath
        if(CheckIfScriptIsRunByAdministrator){
            Log-Info -Message "Script is run as administrator, so enabling" -ConsoleOut
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
        }
        else{
            throw "This script should be executed in administrator mode or above"
        }

        $contextStatus = CheckIfAzContextIsSetOrNot
        if($contextStatus)
        {
            Log-Info -Message "Az Context is set, so proceeding" -ConsoleOut
        }
        else
        {
            throw "Az Context is not set , so cannot proceed with environment preparation, please run Connect-AzAccount and retry"
        }

        if ($null -eq $ClusterName)
        {
            Log-Info -Message "Obtained cluster name is null, so getting the cluster Name from the answer file" -ConsoleOut
            $ClusterName = GetClusterNameFromAnswerFile -AnswerFilePath $AnswerFilePath
            Log-Info -Message "Obtained cluster name from answer file is $ClusterName" -ConsoleOut
        }

        Log-Info -Message "Starting AzStackHci Deployment Initialization" -ConsoleOut

        CreateResourceGroupIfNotExists -ResourceGroupName $ResourceGroup -Region $Region

        Log-Info -Message "Registering Resource providers step" -ConsoleOut
        RegisterRequiredResourceProviders

        Log-Info -Message "Creating cluster and assigning permissions for ARC machines" -ConsoleOut
        CreateClusterAndAssignRoles -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -Region $Region -ClusterName $ClusterName

        Log-Info -Message "Creating storage cloud for witness" -ConsoleOut
        CreateStorageAccountForCloudDeployment -ResourceGroup $ResourceGroup -Region $Region -ClusterName $ClusterName -Prefix $Prefix

        Log-Info -Message "Creating key vault and adding the secrets" -ConsoleOut
        CreateKeyVaultAndAddSecrets -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -Region $Region -LocalAdminCredentials $LocalAdminCredentials -DomainAdminCredentials $DomainAdminCredentials -ClusterName $ClusterName -Prefix $Prefix
    
        Log-Info -Message "Trying to assign the rbac permissions on the Arc Machines" -ConsoleOut
        AssignPermissionsToArcMachines -ArcMachineIds $ArcNodeIds -ResourceGroup $ResourceGroup
        Log-Info -Message "Successfully assigned the rbac permission on the Arc Machines" -ConsoleOut      
        
        Log-Info -Message "Successfully prepared the environment with cluster, storage account and kv" -ConsoleOut
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        $cmdletFailed = $true
        throw $_
    }
    finally {
        $Script:ErrorActionPreference = 'SilentlyContinue'
        Write-AzStackHciFooter -invocation $MyInvocation -Failed:$cmdletFailed -PassThru:$PassThru
        $DebugPreference = "Stop"
    }
}

function Invoke-AzStackHCIEnvironmentValidator {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,
 
        [Parameter(Mandatory = $false, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName,
 
        [Parameter(Mandatory = $true, HelpMessage = "Arc Node ids required for cloud based deployment")]
        [string[]] 
        $ArcNodeIds,
 
        [Parameter(Mandatory = $true, HelpMessage = "Answer file path required for deployment")]
        [string] 
        $AnswerFilePath,
 
        [Parameter(Mandatory = $false, HelpMessage = "Return PSObject result.")]
        [System.Collections.Hashtable] $Tag,
 
        [Parameter(Mandatory = $false, HelpMessage = "Directory path for log and report output")]
        [string]$OutputPath,
 
        [Parameter(Mandatory = $false)]
        [Switch] $Force,

        [Parameter(Mandatory = $false, HelpMessage = "Prefix to uniquely identify a storage account and a keyvault")]
        [string] $Prefix
    )
    try {
        $script:ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        $DebugPreference = "Continue"
        Set-AzStackHciOutputPath -Path $OutputPath
        if(CheckIfScriptIsRunByAdministrator){
            Log-Info -Message "Script is run as administrator, so enabling" -ConsoleOut
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
        }
        else{
            throw "This script should be executed in administrator mode or above"
        }
        
        $contextStatus = CheckIfAzContextIsSetOrNot
        if($contextStatus)
        {
            Log-Info -Message "Az Context is set, so proceeding" -ConsoleOut
        }
        else
        {
            throw "Az Context is not set , so cannot proceed with environment validation, please run Connect-AzAccount and retry"
        }

        if ($null -eq $ClusterName)
        {
            Log-Info -Message "Obtained cluster name is null, so getting the cluster Name from the answer file" -ConsoleOut
            $ClusterName = GetClusterNameFromAnswerFile -AnswerFilePath $AnswerFilePath
            Log-Info -Message "Obtained cluster name from answer file is $ClusterName" -ConsoleOut
        }

        Log-Info -Message "Starting Deployment Settings Validation Operation" -ConsoleOut

        $storageAccountName = GetStorageAccountName -ClusterName $ClusterName -Prefix $Prefix
        $KVName = GetKeyVaultName -ClusterName $ClusterName -Prefix $Prefix
        $deploymentSettingsObject = Get-Content $AnswerFilePath | ConvertFrom-Json
        if ($null -eq $deploymentSettingsObject){
            throw "Deployment Settings Object cannot be null"
        }
        Log-Info -Message "Deployment Settings Object obtained is $deploymentSettingsObject" -ConsoleOut

        $kvResource = Get-AzResource -Name $KVName -ResourceType "Microsoft.KeyVault/vaults" -ResourceGroupName $ResourceGroup
        $kvVaultUri = $kvResource.Properties.vaultUri
        Log-Info -Message "Key Vault Uri obtained is $kvVaultUri" -ConsoleOut

        # Will Trigger Validate first
        $deploymentSettingsParameters = ReplaceDeploymentSettingsParametersTemplateWithActualValues -deploymentSettingsObject $deploymentSettingsObject -clusterName $ClusterName -arcNodeResourceIds $ArcNodeIds -storageAccountName $storageAccountName -secretsLocation $kvVaultUri
        if ($null -eq $deploymentSettingsParameters){
            throw "Deployment Settings Parameters cannot be null"
        }
        $deploymentSettingsParameters.parameters.deploymentMode.value = "Validate"

        Log-Info -Message "Deployment settings parameters obtained is $deploymentSettingsParameters" -ConsoleOut
        
        $deploymentSettingsParametersJson = $deploymentSettingsParameters | ConvertTo-Json -Depth 100
        Log-Info -Message "Deployment Settings Parameters to json is $deploymentSettingsParametersJson" -ConsoleOut

        $updatedDeploymentSettingsParametersFilePath = (Join-Path  -Path $env:TEMP -ChildPath "\DeploymentSettingsReportedPropertiesValidate.json")
        Log-Info -Message "Updated Deployment Settings Parameters File Path $updatedDeploymentSettingsParametersFilePath" -ConsoleOut
        Set-Content -Path $updatedDeploymentSettingsParametersFilePath -Value $deploymentSettingsParametersJson | Out-Null

        $deploymentSettingsTemplateFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Templates\DeploymentSettingsTemplate.json")
        $deploymentIdentifier = [guid]::NewGuid().ToString().Split("-")[0]
        $deploymentSettingsValidationName = $ResourceGroup + "-DSValidate" + $deploymentIdentifier
        Log-Info -Message "Deployment Settings Template File Path $deploymentSettingsTemplateFilePath and Deployment Name $deploymentSettingsDeploymentName" -ConsoleOut

        $resourceGroupDeploymentStatus = New-AzResourceGroupDeployment -Name $deploymentSettingsValidationName -ResourceGroupName $ResourceGroup -TemplateFile $deploymentSettingsTemplateFilePath -TemplateParameterFile $updatedDeploymentSettingsParametersFilePath -Force -Verbose -AsJob
        $deploystatusString = $resourceGroupDeploymentStatus | Out-String
        Log-Info -Message "Triggered Validated the deployment Settings Resource $deploystatusString" -ConsoleOut

        Start-Sleep -Seconds 120
        $entireDeploymentStatus = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -Name $deploymentSettingsValidationName
        $deploymentStatus = $entireDeploymentStatus | Format-Table ResourceGroupName, DeploymentName, ProvisioningState
        $deploystatusString = $deploymentStatus | Out-String 
        Log-Info -Message "Triggered Validated the deployment Settings Resource $deploystatusString" -ConsoleOut

        if ($deploymentStatus.ProvisioningState -eq "Failed")
        {
            Log-Info -Message "The deployment status is already in a failed state , Entire deployment Status : $entireDeploymentStatus" -ConsoleOut
            throw "The deployment status is in a failed state, status =  $deploymentStatus"
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    finally {
        $Script:ErrorActionPreference = 'SilentlyContinue'
        Write-AzStackHciFooter -invocation $MyInvocation -Failed:$cmdletFailed -PassThru:$PassThru
        $DebugPreference = "Stop"
    }
}

function Invoke-AzStackHCIDeployment {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,
 
        [Parameter(Mandatory = $false, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName,
 
        [Parameter(Mandatory = $true, HelpMessage = "Arc Node ids required for cloud based deployment")]
        [string[]] 
        $ArcNodeIds,
 
        [Parameter(Mandatory = $true, HelpMessage = "Answer file path required for deployment")]
        [string] 
        $AnswerFilePath,
 
        [Parameter(Mandatory = $false, HelpMessage = "Return PSObject result.")]
        [System.Collections.Hashtable] $Tag,
 
        [Parameter(Mandatory = $false, HelpMessage = "Directory path for log and report output")]
        [string]$OutputPath,
 
        [Parameter(Mandatory = $false)]
        [Switch] $Force,

        [Parameter(Mandatory = $false, HelpMessage = "Prefix to uniquely identify a storage account and a keyvault")]
        [string] $Prefix
    )
    try {
        $script:ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        $DebugPreference = "Continue"
        Set-AzStackHciOutputPath -Path $OutputPath
        if(CheckIfScriptIsRunByAdministrator){
            Log-Info -Message "Script is run as administrator, so enabling" -ConsoleOut
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
        }
        else{
            throw "This script should be executed in administrator mode or above"
        }
        
        $contextStatus = CheckIfAzContextIsSetOrNot
        if($contextStatus)
        {
            Log-Info -Message "Az Context is set, so proceeding" -ConsoleOut
        }
        else
        {
            throw "Az Context is not set , so cannot proceed with deployment, please run Connect-AzAccount and retry"
        }

        if ($null -eq $ClusterName)
        {
            Log-Info -Message "Obtained cluster name is null, so getting the cluster Name from the answer file" -ConsoleOut
            $ClusterName = GetClusterNameFromAnswerFile -AnswerFilePath $AnswerFilePath
            Log-Info -Message "Obtained cluster name from answer file is $ClusterName" -ConsoleOut
        }

        Log-Info -Message "Starting Deployment Settings Validation Operation" -ConsoleOut

        $storageAccountName = GetStorageAccountName -ClusterName $ClusterName -Prefix $Prefix
        $KVName = GetKeyVaultName -ClusterName $ClusterName -Prefix $Prefix
        $deploymentSettingsObject = Get-Content $AnswerFilePath | ConvertFrom-Json
        if ($null -eq $deploymentSettingsObject){
            throw "Deployment Settings Object cannot be null"
        }
        Log-Info -Message "Deployment Settings Object obtained is $deploymentSettingsObject" -ConsoleOut

        $kvResource = Get-AzResource -Name $KVName -ResourceType "Microsoft.KeyVault/vaults" -ResourceGroupName $ResourceGroup
        $kvVaultUri = $kvResource.Properties.vaultUri
        Log-Info -Message "Key Vault Uri obtained is $kvVaultUri" -ConsoleOut

        # Will Trigger Deployment
        $deploymentSettingsParameters = ReplaceDeploymentSettingsParametersTemplateWithActualValues -deploymentSettingsObject $deploymentSettingsObject -clusterName $ClusterName -arcNodeResourceIds $ArcNodeIds -storageAccountName $storageAccountName -secretsLocation $kvVaultUri
        if ($null -eq $deploymentSettingsParameters){
            throw "Deployment Settings Parameters cannot be null"
        }
        $deploymentSettingsParameters.parameters.deploymentMode.value = "Deploy"

        Log-Info -Message "Deployment settings parameters obtained is $deploymentSettingsParameters" -ConsoleOut
        
        $deploymentSettingsParametersJson = $deploymentSettingsParameters | ConvertTo-Json -Depth 100
        Log-Info -Message "Deployment Settings Parameters to json is $deploymentSettingsParametersJson" -ConsoleOut

        $updatedDeploymentSettingsParametersFilePath = (Join-Path  -Path $env:TEMP -ChildPath "\DeploymentSettingsReportedPropertiesDeploy.json")
        Log-Info -Message "Updated Deployment Settings Parameters File Path $updatedDeploymentSettingsParametersFilePath" -ConsoleOut
        Set-Content -Path $updatedDeploymentSettingsParametersFilePath -Value $deploymentSettingsParametersJson | Out-Null

        $deploymentSettingsTemplateFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Templates\DeploymentSettingsTemplate.json")
        $deploymentIdentifier = [guid]::NewGuid().ToString().Split("-")[0]
        $deploymentSettingsValidationName = $ResourceGroup + "-DSDeploy" + $deploymentIdentifier
        Log-Info -Message "Deployment Settings Template File Path $deploymentSettingsTemplateFilePath and Deployment Name $deploymentSettingsDeploymentName" -ConsoleOut

        New-AzResourceGroupDeployment -Name $deploymentSettingsValidationName -ResourceGroupName $ResourceGroup -TemplateFile $deploymentSettingsTemplateFilePath -TemplateParameterFile $updatedDeploymentSettingsParametersFilePath -Force -Verbose -AsJob
        Start-Sleep -Seconds 120
        $deploymentStatus = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -Name $deploymentSettingsValidationName  
        $deploystatusString = $deploymentStatus | Out-String 
        Log-Info -Message "Triggered the deployment Settings Resource in deploy mode:  $deploystatusString " -ConsoleOut
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    finally {
        $Script:ErrorActionPreference = 'SilentlyContinue'
        Write-AzStackHciFooter -invocation $MyInvocation -Failed:$cmdletFailed -PassThru:$PassThru
        $DebugPreference = "Stop"
    }
}

function Invoke-AzStackHCIFullDeployment {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,
          
        # AzureCloud , AzureUSGovernment , AzureChinaCloud 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Cloud type used for HCI Cluster Deployment. Valid values are : AzureCloud , AzureUSGovernment , AzureChinaCloud")]
        [string] 
        $Cloud,
         
        [Parameter(Mandatory = $true, HelpMessage = "Azure Region used for HCI Cluster Deployment")]
        [string] 
        $Region,
 
        [Parameter(Mandatory = $false, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName,
 
        [Parameter(Mandatory = $true, HelpMessage = "Local Admin Credentials Required for deployment")]
        [System.Management.Automation.PSCredential]
        $LocalAdminCredentials,
         
        [Parameter(Mandatory = $true, HelpMessage = "Cloud Admin Credentials Required for deployment")]
        [System.Management.Automation.PSCredential] 
        $DomainAdminCredentials,
 
        [Parameter(Mandatory = $true, HelpMessage = "Arc Node ids required for cloud based deployment")]
        [string[]] 
        $ArcNodeIds,
 
        [Parameter(Mandatory = $true, HelpMessage = "Answer file path required for deployment")]
        [string] 
        $AnswerFilePath,
 
        [Parameter(Mandatory = $false, HelpMessage = "Return PSObject result.")]
        [System.Collections.Hashtable] $Tag,
 
        [Parameter(Mandatory = $false, HelpMessage = "Directory path for log and report output")]
        [string]$OutputPath,
 
        [Parameter(Mandatory = $false)]
        [Switch] $Force,

        [Parameter(Mandatory = $false, HelpMessage = "Prefix to uniquely identify a storage account and a keyvault")]
        [string] $Prefix
    )
    try {
        $script:ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        $DebugPreference = "Continue"
        Set-AzStackHciOutputPath -Path $OutputPath
        if(CheckIfScriptIsRunByAdministrator){
            Log-Info -Message "Script is run as administrator, so enabling"
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
        }
        else{
            throw "This script should be executed in administrator mode or above"
        }

        $contextStatus = CheckIfAzContextIsSetOrNot
        if($contextStatus)
        {
            Log-Info -Message "Az Context is set, so proceeding" -ConsoleOut
        }
        else
        {
            throw "Az Context is not set , so cannot proceed with environment preparation, please run Connect-AzAccount and retry"
        }

        if ($null -eq $ClusterName)
        {
            Log-Info -Message "Obtained cluster name is null, so getting the cluster Name from the answer file" -ConsoleOut
            $ClusterName = GetClusterNameFromAnswerFile -AnswerFilePath $AnswerFilePath
            Log-Info -Message "Obtained cluster name from answer file is $ClusterName" -ConsoleOut
        }
        Log-Info -Message "Starting AzStackHci Full Deployment" -ConsoleOut

        $environmentPreparationParameters = @{
            SubscriptionID = $SubscriptionID
            ResourceGroup = $ResourceGroup
            Region = $Region
            ClusterName = $ClusterName
            LocalAdminCredentials = $LocalAdminCredentials
            DomainAdminCredentials = $DomainAdminCredentials
            ArcNodeIds = $ArcNodeIds
            Tag = $Tag
            OutputPath = $OutputPath
            Force = $Force
            Prefix = $Prefix
        }
        Log-Info -Message "Successfully got the parameters for environment validation" -ConsoleOut
        Invoke-AzStackHCIEnvironmentPreparator @environmentPreparationParameters

        Log-Info -Message "Successfully prepared the environment for cloud deployment, triggering validation"

        $deploymentSettingsParameters = @{
            SubscriptionID = $SubscriptionID
            ResourceGroup = $ResourceGroup
            Region = $Region
            ClusterName = $ClusterName
            ArcNodeIds = $ArcNodeIds
            AnswerFilePath = $AnswerFilePath
            Tag = $Tag
            OutputPath = $OutputPath
            Force = $Force
            Prefix = $Prefix
        }
        Log-Info -Message "Successfully got the parameters for deployment settings validation" -ConsoleOut
        Invoke-AzStackHCIEnvironmentValidator @deploymentSettingsParameters

        Log-Info -Message "Started polling on the environment validation status"
        PollDeploymentSettingsStatus -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -ClusterName $ClusterName
        Log-Info -Message "Environment Validation succeeded , so moving to the deployment stage" -ConsoleOut
        
        Invoke-AzStackHCIDeployment @deploymentSettingsParameters
        Log-Info -Message "Starting polling on the deployment action plan"
        PollDeploymentSettingsStatus -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -ClusterName $ClusterName
        Log-Info -Message "Congrats, the Azure Stack HCI cluster has been deployed successfully"
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        $cmdletFailed = $true
        Log-Info -Message "Clearing the resource group since deployment failed"
        Remove-AzResourceGroup -Name $ResourceGroup -Force -Verbose
        throw $_
    }
    finally {
        $Script:ErrorActionPreference = 'SilentlyContinue'
        Write-AzStackHciFooter -invocation $MyInvocation -Failed:$cmdletFailed -PassThru:$PassThru
        $DebugPreference = "Stop"
    }
     
}

function Invoke-validateNodesForDeployment
{
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,

        # AzureCloud , AzureUSGovernment , AzureChinaCloud 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Cloud type used for HCI Cluster Deployment. Valid values are : AzureCloud , AzureUSGovernment , AzureChinaCloud")]
        [string] 
        $Cloud,
         
        [Parameter(Mandatory = $true, HelpMessage = "Azure Region used for HCI Cluster Deployment")]
        [string] 
        $Region,        

        [Parameter(Mandatory = $true, HelpMessage = "Arc Node ids required for cloud based deployment")]
        [string[]] 
        $ArcNodeIds,

        [Parameter(Mandatory = $false, HelpMessage = "Directory path for log and report output")]
        [string]$OutputPath
    )
    try
    {
        $script:ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        $DebugPreference = "Continue"
        Set-AzStackHciOutputPath -Path $OutputPath
        $contextStatus = CheckIfAzContextIsSetOrNot
        if($contextStatus)
        {
            Log-Info -Message "Az Context is set, so proceeding" -ConsoleOut
        }
        else
        {
            throw "Az Context is not set , so cannot proceed with environment preparation, please run Connect-AzAccount and retry"
        }

        $RPAPIVersion = "2023-08-01-preview"
        $edgeDeviceNodeIds=@()
        foreach ($arcResourceID in $ArcNodeIds) 
        {
            $edgeDeviceNodeIds += "$($arcResourceID)/providers/Microsoft.AzureStackHCI/edgeDevices/default"
        }

        $edgeDevicesValidateEndpointWithAPI = "{0}/validate?api-version={1}" -f $edgeDeviceNodeIds[0], $RPAPIVersion
        Log-Info -Message "Validation Endpoint Uri : $edgeDevicesValidateEndpointWithAPI" -ConsoleOut
    
        $parameters = @{EdgeDeviceIds=$edgeDeviceNodeIds}
        $jsonString = $parameters | ConvertTo-Json
        Log-Info -Message "Validation action payload : $($jsonString) " -ConsoleOut
        $response = Invoke-AzRestMethod -Path $edgeDevicesValidateEndpointWithAPI -Method POST -Payload $jsonString
        Log-Info -Message "Validation action response : $($response.StatusCode) " -ConsoleOut
        $asyncURL = $response.Headers.GetValues("Azure-AsyncOperation")
        $stopLoop = $false
        $status = $false
        do 
        {
            Log-Info -Message "Querying validation status using : $asyncURL[0]  " -ConsoleOut
            $response = Invoke-AzRestMethod -URI $asyncURL[0] -Method GET
            Log-Info -Message "validation Response: $response " -ConsoleOut
            $validationResponse = $response.Content | ConvertFrom-Json
            $prettyResponse = $validationResponse | ConvertTo-Json -Depth 100
            Log-Info -Message "Validation status $prettyResponse" -ConsoleOut
            if( $validationResponse.status.Equals("Inprogress") -or $validationResponse.status.Equals("Accepted") )
            {
                Start-Sleep -Seconds 10
            }
            else
            {
                $stopLoop = $true
                Log-Info -Message "Validation has completed, checking whether validation has succeeded" -ConsoleOut
                $status = $validationResponse.status.Equals("Succeeded")
                Log-Info -Message "Validation Response succeeded status $status" -ConsoleOut
            }        
        }
        While (-Not $stopLoop)
    }
    catch
    {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        $status = $false
        throw $_
    }
    finally
    {
        $Script:ErrorActionPreference = 'SilentlyContinue'
        Write-AzStackHciFooter -invocation $MyInvocation -Failed:$cmdletFailed -PassThru:$PassThru
        $DebugPreference = "Stop"
    }
    if ($status)
    {
        Log-Info -Message "The status of node validation is successful" -ConsoleOut
        return $status
    }
    else
    {
        throw "Node validation was unsuccessful, check the logs to debug the issue"
    }
}

function CheckIfAzContextIsSetOrNot {
    try {
        $context = Get-AzContext
        if ([string]::IsNullOrEmpty($context)){
            Log-Info -Message "Az Context is Not Set, so cannot run the operation" -ConsoleOut
            return $false
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        return $false
    }
    return $true
}
function GetClusterNameFromAnswerFile {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Answer File Path")]
        [string] 
        $AnswerFilePath
    )
    try {
        $deploymentSettingsObject = Get-Content $AnswerFilePath | ConvertFrom-Json
        if ($null -eq $deploymentSettingsObject){
            throw "Deployment Settings Object cannot be null"
        }
        $deploymentDataFromAnswerFile = $deploymentSettingsObject.ScaleUnits[0].DeploymentData
        $clusterName = $deploymentDataFromAnswerFile.Cluster.Name
        Log-Info -Message "Cluster Name obtained in answer file is $clusterName" -ConsoleOut
        if ($null -ne $clusterName)
        {
            Log-Info -Message "Cluster Name is not null, so returning clustername $clusterName" -ConsoleOut
            return $clusterName
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    return $null
}

function CreateKeyVaultAndAddSecrets {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory = $true, HelpMessage = "Azure Region used for HCI Cluster Deployment")]
        [string] 
        $Region,
 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName,

        [Parameter(Mandatory = $true, HelpMessage = "Local Admin Credentials Required for deployment")]
        [System.Management.Automation.PSCredential]
        $LocalAdminCredentials,
         
        [Parameter(Mandatory = $true, HelpMessage = "Cloud Admin Credentials Required for deployment")]
        [System.Management.Automation.PSCredential] 
        $DomainAdminCredentials,

        [Parameter(Mandatory = $false, HelpMessage = "Prefix to uniquely identify a storage account and a keyvault")]
        [string] $Prefix
    )
    try {
        Log-Info -Message "Initializing the flow where the kv creation starts" -ConsoleOut
        $storageAccountName = GetStorageAccountName -ClusterName $ClusterName -Prefix $Prefix
        $KVName = GetKeyVaultName -ClusterName $ClusterName -Prefix $Prefix
        $storageWitnessKey = GetStorageWitnessKey -SubscriptionId $SubscriptionID -ResourceGroup $ResourceGroup -StorageAccountName $storageAccountName
        if ($null -eq $storageWitnessKey){
            throw "Storage Witness Key is null, so cannot proceed with deployment"
        }
        Log-Info -Message "Successfully received the storage witness key for storage account $storageAccountName" -ConsoleOut
        $storageWitnessKeyB64Encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($storageWitnessKey))
        #Starting to create the spn for ARB Deployment
        $spnDisplayName = GetSpnName -ClusterName $ClusterName -Prefix $Prefix
        $servicePrincialCreds = CreateServicePrincipalForCloudDeployment -DisplayName $spnDisplayName -ResourceGroup $ResourceGroup
        if ($null -eq $servicePrincialCreds){
            throw "Service Principal Credentials are null, so cannot proceed with deployment"
        }
        Log-Info -Message "Successfully created the service principal and the corresponding credentials to put in the kv" -ConsoleOut

        Log-Info -Message "Starting Key Vault Creation...." -ConsoleOut

        $localAdminSecret = ExtractUsernameAndPasswordFromCredential -Credential $LocalAdminCredentials
        if ($null -eq $localAdminSecret){
            throw "Local Admin secret cannot be null, so cannot proceed with deployment"
        }
        Log-Info -Message "Successfully extracted and encoded the Local Admin Credentials"

        $domainAdminSecret = ExtractUsernameAndPasswordFromCredential -Credential $DomainAdminCredentials
        if ($null -eq $domainAdminSecret){
            throw "Domain Admin secret cannot be null, so cannot proceed with deployment"
        }
        Log-Info -Message "Successfully extracted and encoded the Domain Admin Credentials"

        $keyVaultParameters = ReplaceKeyVaultTemplateWithActualValues -KVName $KVName -Region $Region -LocalAdminSecret $localAdminSecret -DomainAdminSecret $domainAdminSecret -ArbDeploymentSpnSecret $servicePrincialCreds -StorageWitnessKey $storageWitnessKeyB64Encoded
        if ($null -eq $keyVaultParameters){
            throw "Key Vault parameters file could not be updated with actual values"
        }
        $deploymentIdentifier = [guid]::NewGuid().ToString().Split("-")[0]
        $KVDeploymentName = $KVName + "-KVDeploy" + $deploymentIdentifier
        $kvTemplateFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Templates\KeyVaultTemplate.json")
        Log-Info -Message "Key Vault Template file path $kvTemplateFilePath" -ConsoleOut
        $keyVaultParametersJson = $keyVaultParameters | ConvertTo-Json
        Log-Info -Message "Json value of key vault parameters $keyVaultParametersJson" -ConsoleOut
        $updatedKVParametersFilePath = (Join-Path  -Path $env:TEMP -ChildPath "\KeyVaultReportedParameters.json")
        Set-Content -Path $updatedKVParametersFilePath -Value $keyVaultParametersJson | Out-Null
        New-AzResourceGroupDeployment -Name $KVDeploymentName -ResourceGroupName $ResourceGroup -TemplateFile $kvTemplateFilePath -TemplateParameterFile $updatedKVParametersFilePath -Force
        $kvDeploymentStatus = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -DeploymentName $KVDeploymentName
        if ($kvDeploymentStatus.ProvisioningState -eq "Succeeded"){
            Log-Info -Message "Successfully deployed the KV with name $KVName" -ConsoleOut
        }
        else{
            throw "KV Deployment Failed so not proceeding with the deployment"
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function CreateStorageAccountForCloudDeployment {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,
 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Region used for HCI Cluster Deployment")]
        [string] 
        $Region,
 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName,

        [Parameter(Mandatory = $false, HelpMessage = "Prefix to uniquely identify a storage account and a keyvault")]
        [string] $Prefix
    )
    try {
        Log-Info -Message "Starting to create the storage account for deployment" -ConsoleOut
        #Perform Storage Account Deployment here

        $storageAccountName = GetStorageAccountName -ClusterName $ClusterName -Prefix $Prefix
        $deploymentIdentifier = [guid]::NewGuid().ToString().Split("-")[0]
        $storageAccountDeploymentName = $storageAccountName + "sadeployment" + $deploymentIdentifier
        Log-Info -Message "Trying to create storage account with name $storageAccountName and Deployment Name $storageAccountDeploymentName" -ConsoleOut
        $storageAccountParameters = ReplaceStorageAccountTemplateWithActualValues -StorageAccountName $storageAccountName -Location $Region
        if ($null -ne $storageAccountParameters){
            $storageAccountTemplateFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Templates\StorageAccountTemplate.json")
            Log-Info -Message "Storage Account Template File Path $storageAccountTemplateFilePath"
            $storageAccountParametersJson = $storageAccountParameters | ConvertTo-Json
            Log-Info -Message "Storage Account Parameters Converted to JSON is $storageAccountParametersJson" -ConsoleOut
            $updatedStorageAccountParametersFilePath = (Join-Path  -Path $env:TEMP -ChildPath "\StorageAccountReportedParameters.json")
            Log-Info -Message "Updated Storage Account Parameters File Path is $updatedStorageAccountParametersFilePath" -ConsoleOut
            Set-Content -Path $updatedStorageAccountParametersFilePath -Value $storageAccountParametersJson | Out-Null
            New-AzResourceGroupDeployment -Name $storageAccountDeploymentName -ResourceGroupName $ResourceGroup -TemplateFile $storageAccountTemplateFilePath -TemplateParameterFile $updatedStorageAccountParametersFilePath -Force
            $statusOfStorageAccountDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -DeploymentName $storageAccountDeploymentName
            if ($statusOfStorageAccountDeployment.ProvisioningState -eq "Succeeded"){
                Log-Info -Message "Storage Account $storageAccountName is created successfully" -ConsoleOut
            }
            else{
                throw "Storage account deployment with name $storageAccountName and deploymentName $storageAccountDeploymentName failed"
            }
        }
        else{
            throw "Could not replace storage account parameter template with the parameter values"
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function CreateClusterAndAssignRoles {
    [CmdletBinding(DefaultParametersetName = 'AZContext')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,

        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,
 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Region used for HCI Cluster Deployment")]
        [string] 
        $Region,
 
        [Parameter(Mandatory = $true, HelpMessage = "Azure Stack HCI Cluster Name for Registration")]
        [string] 
        $ClusterName
    )
    try {
        # Checking if cluster is already deployed
        DeleteClusterResourceIfAlreadyExists -ClusterName $ClusterName -SubscriptionID $SubscriptionID -ResourceGroupName $ResourceGroup

        # Trying to create the cluster object
        $properties = [ResourceProperties]::new($Region, @{})
        $payload = ConvertTo-Json -InputObject $properties
        Log-Info -Message "Payload for cluster creation is $payload" -ConsoleOut
        $resourceId = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroup/providers/Microsoft.AzureStackHCI/clusters/$ClusterName"
        $RPAPIVersion = "2023-08-01-preview"
        $resourceIdApiVersion = "{0}?api-version={1}" -f $resourceId, $RPAPIVersion
        Log-Info -Message "Resource Id is $resourceId" -ConsoleOut
        $clusterResult = New-ClusterWithRetries -ResourceIdWithAPI $resourceIdApiVersion -Payload $payload
        if ($clusterResult -eq $false) {
            throw "Cluster creation with name $ClusterName failed in $Region with Resource Group $ResourceGroup"
        }

        $clusterResource = Get-AzResource -ResourceId $resourceId -ApiVersion $RPAPIVersion -ErrorAction SilentlyContinue
        if ($null -ne $clusterResource) {
            Log-Info -Message "Successfully created the cluster resource $clusterResource" -ConsoleOut

            #Assigning permission to the HCI first party object id on the resource group level
            AssignRolesToHCIResourceProvider -ResourceGroup $ResourceGroup -hciObjectId $clusterResource.Properties.resourceProviderObjectId
        }
        else {
            throw "Cluster creation with name $ClusterName failed in $Region with Resource Group $ResourceGroup"
        }

    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function PollDeploymentSettingsStatus {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription Id for HCI Cluster Deployment")]
        [string]
        $SubscriptionID,
          
        [Parameter(Mandatory = $true, HelpMessage = "Azure Resource group used for HCI Cluster Deployment")]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string] $ClusterName
    )
    $RPAPIVersion = "2023-08-01-preview"
    $deploymentSettingsResourceUri = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroup/providers/Microsoft.AzureStackHCI/clusters/$ClusterName/deploymentSettings/default"
    Log-Info -Message "Deployment Settings Resource Uri is $deploymentSettingsResourceUri" -ConsoleOut
    $stopLoop = $false
    $status = $false
    $currentDeploymentSettingsResource = $null
    do {
        $deploymentSettingsResource = Get-AzResource -ResourceId $deploymentSettingsResourceUri -ApiVersion $RPAPIVersion -Verbose
        Log-Info -Message "Deployment Settings Resource obtained is $deploymentSettingsResource" -ConsoleOut
        $provisioningState = $deploymentSettingsResource.properties.provisioningState
        if (("Succeeded" -eq $provisioningState) -or ("Failed" -eq $provisioningState)){
            $stopLoop = $true
            $currentDeploymentSettingsResource = $deploymentSettingsResource
            if (("Succeeded" -eq $provisioningState)){
                $status = $true
            }
            Log-Info -Message "Provisioning State has reached a terminal state, so closing the operation" -ConsoleOut
        }
        $reportedProperties = $deploymentSettingsResource.properties.reportedProperties
        $reportedPropertiesJson = $reportedProperties | ConvertTo-Json
        Log-Info -Message "Reported Properties obtained is $reportedPropertiesJson" -ConsoleOut
        Start-Sleep -Seconds 120
    }
    While (-Not $stopLoop)
    if (-not $status)
    {
        Log-Info -Message "The current deployment settings resource is in failed state, so throwing an exception" -ConsoleOut
        throw "Deployment Settings resource is in Failed state , current deployment settings resource = $currentDeploymentSettingsResource"
    }
}

function RegisterRequiredResourceProviders {
    try {
        Log-Info -Message "Registering required resource providers" -ConsoleOut
        Register-RPIfRequired -ProviderNamespace "Microsoft.HybridCompute"
        Register-RPIfRequired -ProviderNamespace "Microsoft.GuestConfiguration"
        Register-RPIfRequired -ProviderNamespace "Microsoft.HybridConnectivity"
        Register-RPIfRequired -ProviderNamespace "Microsoft.AzureStackHCI"
        Register-RPIfRequired -ProviderNamespace "Microsoft.Storage"
        Register-RPIfRequired -ProviderNamespace "Microsoft.KeyVault"
        Register-RPIfRequired -ProviderNamespace "Microsoft.ResourceConnector"
        Register-RPIfRequired -ProviderNamespace "Microsoft.HybridContainerService"
        Log-Info -Message "Successfully registered Resource Providers" -ConsoleOut
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    
}

function Register-RPIfRequired{
    param(
        [string] $ProviderNamespace
    )
    $rpState = Get-AzResourceProvider -ProviderNamespace $ProviderNamespace
    $notRegisteredResourcesForRP = ($rpState.Where({$_.RegistrationState  -ne "Registered"}) | Measure-Object ).Count
    if ($notRegisteredResourcesForRP -eq 0 )
    { 
        Log-Info -Message "$ProviderNamespace RP already registered, skipping registration" -ConsoleOut
    } 
    else
    {
        try
        {
            Register-AzResourceProvider -ProviderNamespace $ProviderNamespace | Out-Null
            Log-Info -Message "registered Resource Provider: $ProviderNamespace " -ConsoleOut
        }
        catch
        {
            Log-Info -Message  -Message "Exception occured while registering $ProviderNamespace RP, $_" -ConsoleOut   
            throw 
        }
    }
}

function GetStorageAccountName {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ClusterName,

        [Parameter(Mandatory = $false)]
        [string] $Prefix
    )
    try {
        $storageAccountName = $ClusterName + "sa"
        if ([string]::IsNullOrEmpty($Prefix)) {
            Log-Info -Message "Storage account name with null prefix is $storageAccountName" -ConsoleOut
        }
        else {
            $storageAccountName = $storageAccountName + $Prefix
            Log-Info -Message "Storage account name appended with prefix is $storageAccountName" -ConsoleOut
        }
        $storageAccountName = $storageAccountName -replace "[^a-zA-Z0-9]", ""
        $storageAccountName = $storageAccountName.ToLower()
        if ($storageAccountName.Length -gt 24) {
            $storageAccountName = $storageAccountName.Substring(0, 24)
        }
        Log-Info -Message "Storage account name is $storageAccountName" -ConsoleOut
        return $storageAccountName
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function GetKeyVaultName {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ClusterName,

        [Parameter(Mandatory = $false)]
        [string] $Prefix
    )
    try {
        $KVName = $ClusterName + "-KV"
        if ([string]::IsNullOrEmpty($Prefix)) {
            Log-Info -Message "KV Name with without prefix is $KVName" -ConsoleOut
        }
        else {
            $KVName = $KVName + $Prefix
            Log-Info -Message "KV Name with unique prefix provided by user is $KVName" -ConsoleOut
        }
        $KVName = $KVName -replace "[^a-zA-Z0-9]", ""
        $KVName = $KVName.ToLower()
        if ($KVName.Length -gt 24) {
            $KVName = $KVName.Substring(0, 24)
        }
        Log-Info -Message "Key Vault name is $KVName" -ConsoleOut
        return $KVName
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function GetSpnName {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ClusterName,

        [Parameter(Mandatory = $false)]
        [string] $Prefix
    )
    try {
        $spnDisplayName = $ClusterName + "-SPN"
        if ([string]::IsNullOrEmpty($Prefix)) 
        {
            Log-Info -Message "Spn display name without prefix is $spnDisplayName" -ConsoleOut
        }
        else
        {
            $spnDisplayName = $ClusterName + "-SPN" + $Prefix
            Log-Info -Message "Spn display name with prefix is $spnDisplayName" -ConsoleOut
        }
        return $spnDisplayName
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function CheckIfKVAlreadyExists {
    param (
        [Parameter(Mandatory = $true)]
        [string] $KVName,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )
    try {
        $kvAccount = Get-AzResource -Name $KVName -ResourceType "Microsoft.KeyVault/vaults" -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        if (($null -ne $kvAccount) -and ($null -ne $kvAccount.properties.ProvisioningState)){
            $status = $kvAccount.properties.ProvisioningState
            if (($status -eq "Succeeded")){
                Log-Info -Message "Key Vault with the same name $kvAccount exists in the Resource Group $ResourceGroupName" -ConsoleOut
                return [ErrorDetail]::KeyVaultAlreadyExists
            }
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return [ErrorDetail]::NotFound
}

function CheckIfStorageAccountAlreadyExists {
    param (
        [Parameter(Mandatory = $true)]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )
    try {
        $storageAccount = Get-AzResource -Name $StorageAccountName -ResourceType "Microsoft.Storage/storageAccounts" -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        if (($null -ne $storageAccount) -and ($null -ne $storageAccount.properties.ProvisioningState)){
            $status = $storageAccount.properties.ProvisioningState
            if (($status -eq "Succeeded")){
                Log-Info -Message "Storage Account with the same name $StorageAccountName exists in the Resource Group $ResourceGroupName" -ConsoleOut
                return [ErrorDetail]::StorageAccountAlreadyExists
            }
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return [ErrorDetail]::NotFound
}

function DeleteClusterResourceIfAlreadyExists {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ClusterName,

        [Parameter(Mandatory = $true)]
        [string] $SubscriptionID,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )
    try {
        $RPAPIVersion = "2023-08-01-preview"
        $clusterResourceUri = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.AzureStackHCI/clusters/$ClusterName"
        Log-Info -Message "Cluster Resource Uri obtained is $clusterResourceUri" -ConsoleOut
        $stopLoop = $false
        do{
            $clusterResource = Get-AzResource -ResourceId $clusterResourceUri -ApiVersion $RPAPIVersion -ErrorAction SilentlyContinue
            Log-Info -Message "Current cluster resource obtained is $clusterResource" -ConsoleOut
            if ($null -ne $clusterResource)
            {
                Log-Info -Message "Current cluster resource is not null, so deleting the cluster resource" -ConsoleOut
                Remove-AzResource -ResourceId $clusterResourceUri -Force
                Log-Info -Message "Successfully triggered delete of the cluster resource $clusterResourceUri" -ConsoleOut
            }
            else
            {
                Log-Info -Message "Current cluster resource is deleted, so returning" -ConsoleOut
                $stopLoop = true
            }
            Start-Sleep -Seconds 120
        }
        While (-Not $stopLoop)

        Log-Info -Message "Triggering a force delete of the cluster even though it is null" -ConsoleOut
        Remove-AzResource -ResourceId $clusterResourceUri -Force -ErrorAction SilentlyContinue
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}

function GetStorageWitnessKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string] $StorageAccountName
    )

    try {
        $resourceId = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Storage/storageAccounts/{2}" -f $SubscriptionId, $ResourceGroup, $StorageAccountName
        Log-Info -Message "Resource id of storage account is $resourceId" -ConsoleOut
        $res = Invoke-AzResourceAction -ResourceId $resourceId -Action "listKeys" -ApiVersion "2023-01-01" -Force
        Log-Info -Message "Successfully got the keys for the storage account $StorageAccountName" -ConsoleOut
        if (($null -ne $res) -and ($res.keys.Count -gt 0)){
            return $res.keys[0].value
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return $null
}
function ReplaceDeploymentSettingsParametersTemplateWithActualValues {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $deploymentSettingsObject,

        [Parameter(Mandatory = $true)]
        [string] $clusterName,

        [Parameter(Mandatory = $true)]
        [string[]] $arcNodeResourceIds,

        [Parameter(Mandatory = $true)]
        [string] $storageAccountName,

        [Parameter(Mandatory = $true)]
        [string] $secretsLocation
    )
    try {
        $customLocationName = $clusterName + "-customlocation"
        $deploymentDataFromAnswerFile = $deploymentSettingsObject.ScaleUnits[0].DeploymentData
        $deploymentSettingsParameterFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Parameters\DeploymentSettingsParameters.json")
        $deploymentSettingsParameters = Get-Content $deploymentSettingsParameterFilePath | ConvertFrom-Json
        $deploymentSettingsParameters.parameters.name.value = $clusterName
        $deploymentSettingsParameters.parameters.arcNodeResourceIds.value = $arcNodeResourceIds
        $deploymentSettingsParameters.parameters.domainFqdn.value = $deploymentDataFromAnswerFile.DomainFQDN
        $deploymentSettingsParameters.parameters.namingPrefix.value = $deploymentDataFromAnswerFile.NamingPrefix
        $deploymentSettingsParameters.parameters.adouPath.value = $deploymentDataFromAnswerFile.ADOUPath
        $deploymentSettingsParameters.parameters.driftControlEnforced.value = $deploymentDataFromAnswerFile.SecuritySettings.DriftControlEnforced
        $deploymentSettingsParameters.parameters.credentialGuardEnforced.value = $deploymentDataFromAnswerFile.SecuritySettings.CredentialGuardEnforced
        $deploymentSettingsParameters.parameters.smbSigningEnforced.value = $deploymentDataFromAnswerFile.SecuritySettings.SMBSigningEnforced
        $deploymentSettingsParameters.parameters.smbClusterEncryption.value = $deploymentDataFromAnswerFile.SecuritySettings.SMBClusterEncryption
        $deploymentSettingsParameters.parameters.bitlockerBootVolume.value = $deploymentDataFromAnswerFile.SecuritySettings.BitlockerBootVolume
        $deploymentSettingsParameters.parameters.bitlockerDataVolumes.value = $deploymentDataFromAnswerFile.SecuritySettings.BitlockerDataVolumes
        $deploymentSettingsParameters.parameters.wdacEnforced.value = $deploymentDataFromAnswerFile.SecuritySettings.WDACEnforced
        $deploymentSettingsParameters.parameters.streamingDataClient.value = $deploymentDataFromAnswerFile.Observability.StreamingDataClient
        $deploymentSettingsParameters.parameters.euLocation.value = $deploymentDataFromAnswerFile.Observability.EULocation
        $deploymentSettingsParameters.parameters.episodicDataUpload.value = $deploymentDataFromAnswerFile.Observability.EpisodicDataUpload
        $deploymentSettingsParameters.parameters.clusterName.value =  $clusterName    
        $deploymentSettingsParameters.parameters.cloudAccountName.value = $storageAccountName
        $deploymentSettingsParameters.parameters.configurationMode.value = $deploymentDataFromAnswerFile.Storage.ConfigurationMode
        $deploymentSettingsParameters.parameters.subnetMask.value = $deploymentDataFromAnswerFile.InfrastructureNetwork.SubnetMask
        $deploymentSettingsParameters.parameters.defaultGateway.value = $deploymentDataFromAnswerFile.InfrastructureNetwork.Gateway
        $deploymentSettingsParameters.parameters.startingIPAddress.value = $deploymentDataFromAnswerFile.InfrastructureNetwork.IPPools[0].StartingAddress
        $deploymentSettingsParameters.parameters.endingIPAddress.value = $deploymentDataFromAnswerFile.InfrastructureNetwork.IPPools[0].EndingAddress
        $deploymentSettingsParameters.parameters.dnsServers.value = @($deploymentDataFromAnswerFile.InfrastructureNetwork.DNSServers)
        $deploymentSettingsParameters.parameters.physicalNodesSettings.value = @(GetPhysicalNodesSettingsFromAnswerFile -deploymentData $deploymentDataFromAnswerFile)
        $deploymentSettingsParameters.parameters.storageNetworkList.value = @(GetStorageNetworkListFromDeploymentData -deploymentData $deploymentDataFromAnswerFile)
        $deploymentSettingsParameters.parameters.intentList.value = @(GetNetworkIntents -deploymentData $deploymentDataFromAnswerFile)
        $deploymentSettingsParameters.parameters.customLocation.value = $customLocationName
        $deploymentSettingsParameters.parameters.secretsLocation.value = $secretsLocation

        Log-Info -Message "Deployment Settings Parameters Object $deploymentSettingsParameters" -ConsoleOut
        return $deploymentSettingsParameters
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return $null
}

function GetNetworkIntents {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $deploymentData
    )
    $networkIntents = @()
    try {
        $networkIntentList = $deploymentData.HostNetwork.Intents
        foreach ($intent in $networkIntentList) {
            $networkIntentInfo = New-Object -TypeName PSObject
            $networkIntentInfo | Add-Member -Name 'name' -MemberType Noteproperty -Value $intent.Name
            $networkIntentInfo | Add-Member -Name 'trafficType' -MemberType Noteproperty -Value @($intent.TrafficType)
            $networkIntentInfo | Add-Member -Name 'adapter' -MemberType Noteproperty -Value @($intent.Adapter)
            $networkIntentInfo | Add-Member -Name 'overrideVirtualSwitchConfiguration' -MemberType Noteproperty -Value $intent.OverrideVirtualSwitchConfiguration        
            $networkIntentInfo | Add-Member -Name 'overrideQosPolicy' -MemberType Noteproperty -Value $intent.OverrideQosPolicy      
            $networkIntentInfo | Add-Member -Name 'overrideAdapterProperty' -MemberType Noteproperty -Value $intent.overrideAdapterProperty
        
            $virtualSwitchConfigurationOverrides = New-Object -TypeName PSObject
            $virtualSwitchConfigurationOverrides | Add-Member -Name 'enableIov' -MemberType Noteproperty -Value $intent.VirtualSwitchConfigurationOverrides.EnableIov
            $virtualSwitchConfigurationOverrides | Add-Member -Name 'loadBalancingAlgorithm' -MemberType Noteproperty -Value $intent.VirtualSwitchConfigurationOverrides.LoadBalancingAlgorithm
            $networkIntentInfo | Add-Member -Name 'virtualSwitchConfigurationOverrides' -MemberType Noteproperty -Value $virtualSwitchConfigurationOverrides

            $qosPolicyOverrides = New-Object -TypeName PSObject
            $qosPolicyOverrides | Add-Member -Name 'priorityValue8021Action_Cluster' -MemberType Noteproperty -Value $intent.QosPolicyOverrides.PriorityValue8021Action_Cluster
            $qosPolicyOverrides | Add-Member -Name 'priorityValue8021Action_SMB' -MemberType Noteproperty -Value $intent.QosPolicyOverrides.PriorityValue8021Action_Cluster
            $qosPolicyOverrides | Add-Member -Name 'bandwidthPercentage_SMB' -MemberType Noteproperty -Value $intent.QosPolicyOverrides.BandwidthPercentage_SMB
            $networkIntentInfo | Add-Member -Name 'qosPolicyOverrides' -MemberType Noteproperty -Value $qosPolicyOverrides

            $adapterPropertyOverrides = New-Object -TypeName PSObject
            $adapterPropertyOverrides | Add-Member -Name 'jumboPacket' -MemberType Noteproperty -Value $intent.AdapterPropertyOverrides.JumboPacket
            if( ([string]::IsNullOrEmpty($intent.AdapterPropertyOverrides.NetworkDirect)))
            {
                $adapterPropertyOverrides | Add-Member -Name 'networkDirect' -MemberType Noteproperty -Value "Disabled"
            }else
            {
                $adapterPropertyOverrides | Add-Member -Name 'networkDirect' -MemberType Noteproperty -Value $intent.AdapterPropertyOverrides.NetworkDirect
            }

            $adapterPropertyOverrides | Add-Member -Name 'networkDirectTechnology' -MemberType Noteproperty -Value $intent.AdapterPropertyOverrides.NetworkDirectTechnology
            $networkIntentInfo | Add-Member -Name 'adapterPropertyOverrides' -MemberType Noteproperty -Value $adapterPropertyOverrides
        
            $networkIntents += $networkIntentInfo
            Log-Info -Message "Network Intent Info obtained is $networkIntentInfo" -ConsoleOut
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    
    Log-Info -Message "Network Intents obtained is $networkIntents" -ConsoleOut
    return $networkIntents
}
function GetStorageNetworkListFromDeploymentData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $deploymentData
    )
    $storageNetworks = @()
    try {
        $storageNetworksList = $deploymentData.HostNetwork.StorageNetworks
        foreach ($network in $storageNetworksList) {
            $storageNetworkInfo = New-Object -TypeName psobject
            $storageNetworkInfo | Add-Member -Name 'name' -MemberType Noteproperty -Value $network.Name
            $storageNetworkInfo | Add-Member -Name 'networkAdapterName' -MemberType Noteproperty -Value $network.NetworkAdapterName
            $storageNetworkInfo | Add-Member -Name 'vlanId' -MemberType Noteproperty -Value $network.VlanId.ToString()

            $storageNetworks += $storageNetworkInfo
            Log-Info -Message "Storage Network Setting Info is $storageNetworkInfo" -ConsoleOut
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    Log-Info -Message "Storage Network Settings Obtained is $storageNetworks" -ConsoleOut
    return $storageNetworks
}

function GetPhysicalNodesSettingsFromAnswerFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $deploymentData
    )
    $physicalNodeSettings = @()
    try {
        $physicalNodesData = $deploymentData.PhysicalNodes
        foreach ($settings in $physicalNodesData) {
            $physicalNodeInfo = New-Object -TypeName psobject
            $physicalNodeInfo | Add-Member -Name 'name' -MemberType Noteproperty -Value $settings.Name
            $physicalNodeInfo | Add-Member -Name 'ipv4Address' -MemberType Noteproperty -Value $settings.Ipv4Address
            $physicalNodeSettings += $physicalNodeInfo
            Log-Info -Message "Physical Node Ip info is $physicalNodeInfo" -ConsoleOut
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    Log-Info -Message "Physical Node Settings obtained is $physicalNodeSettings" -ConsoleOut
    return $physicalNodeSettings
}
function AssignPermissionsToArcMachines {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $ArcMachineIds,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup
    )
    try {
        ForEach ($arcMachineUri in $ArcMachineIds) {
            $objectId = GetArcMachineObjectId -ArcMachineUri $arcMachineUri
            if ($null -ne $objectId) {
                $setHCIRegistrationRoleResult = PerformObjectRoleAssignmentWithRetries -ObjectId $objectId -RoleName "Azure Stack HCI Administrator" -ResourceGroup $ResourceGroup -Verbose
                if ($setHCIRegistrationRoleResult -ne [ErrorDetail]::Success) {
                    Log-Info -Message "Failed to assign the Azure Stack HCI Administrator role on the resource group" -ConsoleOut -Type Error
                }
                else {
                    Log-Info -Message "Successfully assigned the Azure Stack HCI Administrator role on the resource group" -ConsoleOut
                }

                $keyVaultSecretsUserRoleResult = PerformObjectRoleAssignmentWithRetries -ObjectId $objectId -RoleName "Key Vault Secrets User" -ResourceGroup $ResourceGroup -Verbose
                if ($keyVaultSecretsUserRoleResult -ne [ErrorDetail]::Success) {
                    Log-Info -Message "Failed to assign the Key Vault Secrets User role on the resource group" -ConsoleOut -Type Error
                }
                else {
                    Log-Info -Message "Successfully assigned the Key Vault Secrets User role on the resource group" -ConsoleOut
                }
            }
            else{
                Log-Info -Message "HCI Object Id is null, so could not assign the required permissions the HCI RP on the RG" -Type Error -ConsoleOut
            }
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
}

function GetArcMachineObjectId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $ArcMachineUri
    )
    try {
        Log-Info -Message "Arc Machine Uri $ArcMachineUri" -ConsoleOut
        $arcResource = Get-AzResource -ResourceId $ArcMachineUri
        $objectId = $arcResource.Identity.PrincipalId
        Log-Info -Message "Successfully got Object Id for Arc Installation $objectId" -ConsoleOut
        return $objectId
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        throw $_
    }
    return $null
}

function ReplaceKeyVaultTemplateWithActualValues {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $KVName,

        [Parameter(Mandatory = $true)]
        [string] $Region,

        [Parameter(Mandatory = $true)]
        [string] $LocalAdminSecret,

        [Parameter(Mandatory = $true)]
        [string] $DomainAdminSecret,

        [Parameter(Mandatory = $true)]
        [string] $ArbDeploymentSpnSecret,

        [Parameter(Mandatory = $true)]
        [string] $StorageWitnessKey
    )
    try {
        Log-Info -Message "Starting to change the parameters of the key vault parameyters template" -ConsoleOut
        $keyVaultParameterFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Parameters\KeyVaultParameters.json")
        $keyVaultParameters = Get-Content $keyVaultParameterFilePath | ConvertFrom-Json
        Log-Info -Message "Successfully got the template file for the key vault parameters" -ConsoleOut
        $keyVaultParameters.parameters.keyVaultName.value = $KVName
        $keyVaultParameters.parameters.location.value = $Region
        $keyVaultParameters.parameters.localAdminSecretValue.value = $LocalAdminSecret
        $keyVaultParameters.parameters.domainAdminSecretValue.value = $DomainAdminSecret
        $keyVaultParameters.parameters.arbDeploymentSpnValue.value = $ArbDeploymentSpnSecret
        $keyVaultParameters.parameters.storageWitnessValue.value = $StorageWitnessKey
        Log-Info -Message "Successfully updated the key vault parameters file with the actual values" -ConsoleOut
        return $keyVaultParameters
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return $null
}

function CreateServicePrincipalForCloudDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $DisplayName,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup
    )
    try {
        $servicePrincipal = New-AzADServicePrincipal -DisplayName $DisplayName
        Start-Sleep -Seconds 120
        $AADApp = Get-AzADApplication -ApplicationId $servicePrincipal.AppId
        Log-Info -Message "Created a spn with the appId $AADApp" -ConsoleOut
        $PasswordCedentials = @{
            StartDateTime = Get-Date
            EndDateTime   = (Get-Date).AddDays(90)
            DisplayName   = ("Secret auto-rotated on: " + (Get-Date).ToUniversalTime().ToString("yyyy'-'MM'-'dd"))
        }
        $servicePrincipalSecret = New-AzADAppCredential -ApplicationObject $AADApp -PasswordCredentials $PasswordCedentials
        $servicePrincipalSecretTest = $servicePrincipalSecret.SecretText
        Log-Info -Message "Successfully created a service principal secret for the app $AADApp" -ConsoleOut

        $spnCredentialForArb = $servicePrincipal.AppId + ":" + $servicePrincipalSecretTest
        $base64EncodedSpnCredential = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($spnCredentialForArb))

        Log-Info -Message "The base 64 encoded spn credential for deployment is created successfully" -ConsoleOut

        Log-Info -Message "Trying to assign permission to the SPN" -ConsoleOut
        AssignPermissionToSPN -spnObjectId $servicePrincipal.Id -ResourceGroup $ResourceGroup

        return $base64EncodedSpnCredential
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return $null
}

function ReplaceStorageAccountTemplateWithActualValues {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true)]
        [string] $Location
    )
    try {
        $storageAccountParameterFilePath = (Join-Path  -Path $PSScriptRoot -ChildPath "Parameters\StorageAccountParameters.json")
        Log-Info -Message "Storage Account Parameters File Path $storageAccountParameterFilePath" -ConsoleOut
        $storageAccountParameters = Get-Content $storageAccountParameterFilePath | ConvertFrom-Json
        $storageAccountParameters.parameters.cloudDeployStorageAccountName.value = $StorageAccountName
        $storageAccountParameters.parameters.location.value = $Location
        Log-Info -Message "Successfully replaced the storage account name in the parameters file" -ConsoleOut
        return $storageAccountParameters
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return $null
}

function ExtractUsernameAndPasswordFromCredential {
    [CmdletBinding()]
    param (
        [System.Management.Automation.PSCredential] $Credential
    )
    try {
        $secretName = $Credential.GetNetworkCredential().UserName
        $secretValue = $Credential.GetNetworkCredential().Password
        Log-Info -Message "Successfully extracted the secret Name $secretName and the secret Value from the Credential Object" -ConsoleOut
        $KVSecret = $secretName + ":" + $secretValue
        $base64EncodedKVSecret = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($KVSecret))
        Log-Info -Message "Successfully base 64 encoded the secret $secretName "
        return $base64EncodedKVSecret
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    return $null
}

function AssignPermissionToSPN {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup,
 
        [Parameter(Mandatory = $true)]
        [string] $spnObjectId
    )
    try {
        if ($null -ne $spnObjectId) {
            $arcManagerRoleStatus = PerformObjectRoleAssignmentWithRetries -ObjectId $spnObjectId -RoleName "User Access Administrator"
            if ($arcManagerRoleStatus -ne [ErrorDetail]::Success) {
                Log-Info -Message "Failed to assign User Access administrator role on the resource group for the SPN" -ConsoleOut -Type Error
            }
            else {
                Log-Info -Message "Successfully assigned the  Access administrator role on the resource group for the SPN" -ConsoleOut
            }
            $arcContributorRoleStatus = PerformObjectRoleAssignmentWithRetries -ObjectId $spnObjectId -RoleName "contributor" 
            if ($arcContributorRoleStatus -ne [ErrorDetail]::Success) {
                Log-Info -Message "Failed to assign User Contributor role on the resource group for the SPN" -ConsoleOut -Type Error
            }
            else {
                Log-Info -Message "Successfully assigned the  Contributor role on the resource group for the SPN" -ConsoleOut
            }
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}


function AssignRolesToHCIResourceProvider {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup,
 
        [Parameter(Mandatory = $true)]
        [string] $hciObjectId
    )
    try {
        if ($null -ne $hciObjectId) {
            $arcManagerRoleStatus = PerformObjectRoleAssignmentWithRetries -ObjectId $hciObjectId -RoleName "Azure Connected Machine Resource Manager" -ResourceGroup $ResourceGroup
            if ($arcManagerRoleStatus -ne [ErrorDetail]::Success) {
                Log-Info -Message "Failed to assign the Azure Connected Machine Resource Nanager role on the resource group" -ConsoleOut -Type Error
            }
            else {
                Log-Info -Message "Successfully assigned the Azure Connected Machine Resource Nanager role on the resource group" -ConsoleOut
            }
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}
 
function PerformObjectRoleAssignmentWithRetries {
    param(
        [String] $ObjectId,
        [String] $ResourceGroup,
        [string] $RoleName
    )
    $stopLoop = $false
    [int]$retryCount = "0"
    [int]$maxRetryCount = "5"
 
    Log-Info -Message $"Checking if $RoleName is assigned already for SPN with Object ID: $ObjectId" -ConsoleOut
    if( [string]::IsNullOrEmpty($ResourceGroup))
    {
        $arcSPNRbacRoles = Get-AzRoleAssignment -ObjectId $ObjectId
    }
    else
    {
        $arcSPNRbacRoles = Get-AzRoleAssignment -ObjectId $ObjectId -ResourceGroupName $ResourceGroup
    }
    
    $alreadyFoundRole = $false
    $arcSPNRbacRoles | ForEach-Object {
        $roleFound = $_.RoleDefinitionName
        if ($roleFound -eq $RoleName) {
            $alreadyFoundRole = $true
            Log-Info -Message $"Already Found $RoleName Not Assigning" -ConsoleOut
        }
    }
    if ( -not $alreadyFoundRole) {
        Log-Info -Message "Assigning $RoleName to Object : $ObjectId" -ConsoleOut
        do {
            try {
                if( [string]::IsNullOrEmpty($ResourceGroup))
                {
                    New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $RoleName | Out-Null                    
                }
                else
                {
                    New-AzRoleAssignment -ObjectId $ObjectId -ResourceGroupName $ResourceGroup -RoleDefinitionName $RoleName | Out-Null
                }

                Log-Info -Message $"Sucessfully assigned $RoleName to Object Id $ObjectId" -ConsoleOut
                $stopLoop = $true
            }
            catch {
                # 'Conflict' can happen when either the RoleAssignment already exists or the limit for number of role assignments has been reached.
                if ($_.Exception.Response.StatusCode -eq 'Conflict') {
                    if( [string]::IsNullOrEmpty($ResourceGroup))
                    {
                        $roleAssignment = Get-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $RoleName                        
                    }
                    else
                    {
                        $roleAssignment = Get-AzRoleAssignment -ObjectId $ObjectId -ResourceGroupName $ResourceGroup -RoleDefinitionName $RoleName
                    }

                    if ($null -ne $roleAssignment) {
                        Log-Info -Message $"Sucessfully assigned $RoleName to Object Id $ObjectId" -ConsoleOut
                        return [ErrorDetail]::Success
                    }
                    Log-Info -Message $"Failed to assign roles to service principal with object Id $($ObjectId). ErrorMessage: " + $_.Exception.Message + " PositionalMessage: " + $_.InvocationInfo.PositionMessage -ConsoleOut -Type Error
                    return [ErrorDetail]::PermissionsMissing
                }
                if ($retryCount -ge $maxRetryCount) {
                    # Timed out.
                    Log-Info -Message $"Failed to assign roles to service principal with object Id $($ObjectId). ErrorMessage: " + $_.Exception.Message + " PositionalMessage: " + $_.InvocationInfo.PositionMessage -ConsoleOut -Type Error
                    return [ErrorDetail]::PermissionsMissing
                }
                Log-Info -Message $"Could not assign roles to service principal with Object Id $($ObjectId). Retrying in 10 seconds..." -ConsoleOut
                Start-Sleep -Seconds 10
                $retryCount = $retryCount + 1
            }
        }
        While (-Not $stopLoop)
    }
    return [ErrorDetail]::Success
}

function CreateResourceGroupIfNotExists {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string] $Region
    )
    try {
        # Check if the resource group exists
        $existingResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

        if (([string]::IsNullOrEmpty($existingResourceGroup)) -or ([string]::IsNullOrEmpty($existingResourceGroup.ResourceGroupName))) {
            # Resource group doesn't exist, create it
            Log-Info -Message "$ResourceGroupName does not exist, creating it" -ConsoleOut
            New-AzResourceGroup -Name $ResourceGroupName -Location $Region -Force | Out-Null
            Log-info -Message "Created the resource group $ResourceGroupName" -ConsoleOut
        }
        else {
            # Resource group already exists
            Log-Info -Message "The resource group '$ResourceGroupName' already exists." -ConsoleOut
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}

function CheckIfScriptIsRunByAdministrator {
    try {
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent()

        # Get the Windows Principal for the current user
        $principal = New-Object System.Security.Principal.WindowsPrincipal($user)

        # Check if the user is in the Administrator role
        $is_admin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($is_admin) {
            Log-Info -Message "User has administrator access" -ConsoleOut
            return $is_admin
        }
        Log-Info -Message "User is not running the script in administrator mode" -ConsoleOut
        return $is_admin
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}

function New-ClusterWithRetries {
    param(
        [String] $ResourceIdWithAPI,
        [String] $Payload
    )
    $stopLoop = $false
    [int]$retryCount = "0"
    [int]$maxRetryCount = "10"
    do {

        $response = Invoke-AzRestMethod -Path $ResourceIdWithAPI -Method PUT -Payload $Payload

        if (($response.StatusCode -ge 200) -and ($response.StatusCode -lt 300)) {
            $stopLoop = $true
            return $true
        }
        if ($retryCount -ge $maxRetryCount) {
            # Timed out.
            Log-Info -Message "Failed to create ARM resource representing the cluster. StatusCode: {0}, ErrorCode: {1}, Details: {2}" -f $response.StatusCode, $response.ErrorCode, $response.Content -Type Error -ConsoleOut
            return $false
        }
        Log-Info -Message "Failed to create ARM resource representing the cluster. Retrying in 10 seconds..." -Type Error -ConsoleOut
        Start-Sleep -Seconds 10
        $retryCount = $retryCount + 1

    }
    While (-Not $stopLoop)
    return $true
}

class Identity {
    [string] $type = "SystemAssigned"
}

class ResourceProperties {
    [string] $location
    [object] $properties
    [Identity] $identity = [Identity]::new()

    ResourceProperties (
        [string] $location,
        [object] $properties
    )
    {
        $this.location = $location
        $this.properties = $properties
    }
}

enum ErrorDetail
{
    Unused;
    PermissionsMissing;
    Success;
    NodeAlreadyArcEnabled;
    NotFound;
    ClusterAlreadyExists;
    ConnectedRecently;
    DeploymentSuccess;
    StorageAccountAlreadyExists;
    KeyVaultAlreadyExists;
    EnvironmentValidationFailed
}
 
Export-ModuleMember -Function Invoke-AzStackHCIDeployment
Export-ModuleMember -Function Invoke-AzStackHCIEnvironmentValidator
Export-ModuleMember -Function Invoke-AzStackHCIEnvironmentPreparator
Export-ModuleMember -Function Invoke-AzStackHCIFullDeployment
Export-ModuleMember -Function PollDeploymentSettingsStatus
Export-ModuleMember -Function Invoke-validateNodesForDeployment