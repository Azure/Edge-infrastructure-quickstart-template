<#############################################################
 #                                                           #
 # Copyright (C) Microsoft Corporation. All rights reserved. #
 #                                                           #
 #############################################################>
Import-Module $PSScriptRoot\Classes\reporting.psm1 -Force -DisableNameChecking -Global
 

function Check-NodeArcRegistrationStateScriptBlock {
    if(Test-Path -Path "C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe")
    {
        $arcAgentStatus = Invoke-Expression -Command "& 'C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe' show -j"
        
        # Parsing the status received from Arc agent
        $arcAgentStatusParsed = $arcAgentStatus | ConvertFrom-Json

        # Throw an error if the node is Arc enabled to a different resource group or subscription id
        # Agent can be is "Connected"  or disconnected state. If the resource name property on the agent is empty, that means, it is cleanly disconnected , and just the exe exists
        # If the resourceName exists and agent is in "Disconnected" state, indicates agent has temporary connectivity issues to the cloud
        if(-not ([string]::IsNullOrEmpty($arcAgentStatusParsed.resourceName)) -or
         -not ([string]::IsNullOrEmpty($arcAgentStatusParsed.subscriptionId))  -or 
         -not ([string]::IsNullOrEmpty($arcAgentStatusParsed.resourceGroup))
         )
        {
            
            $differentResourceExceptionMessage = "Node is already ARC Enabled and connected to Subscription Id: {0}, Resource Group: {1}" -f $arcAgentStatusParsed.subscriptionId, $arcAgentStatusParsed.resourceGroup
            Log-info -Message "$differentResourceExceptionMessage" -Type Error -ConsoleOut
            return [ErrorDetail]::NodeAlreadyArcEnabled
        }
        return [ErrorDetail]::Success
    }
}

function Register-ResourceProviderIfRequired{
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

 function Invoke-AzStackHciArcInitialization
 {
     <#
     .SYNOPSIS
         Perform AzStackHci ArcIntegration Initialization
     .DESCRIPTION
         Initializes ARC integration on Azure Stack HCI node
     .EXAMPLE
         PS C:\> Connect-AzAccount -Tenant $tenantID -Subscription $subscriptionID -DeviceCode
         PS C:\>  $nodeNames = [string[]]("host1","host2","host3","host4")
         PS C:\>  Invoke-AzStackHciArcIntegrationValidation -SubscriptionID $subscriptionID -ArcResourceGroupName $resourceGroupName -NodeNames $nodeNames
     .PARAMETER SubscriptionID
         Specifies the Azure Subscription to create the resource. Is Mandatory Paratmer
     .PARAMETER ResourceGroup
         Specifies the resource group to which ARC resources should be projected. Is Mandatory Paratmer
    .PARAMETER TenantID
         Specifies the Azure TenantId.Required only if ARMAccessToken is used.
    .PARAMETER Cloud
         Specifies the Azure Environment. Valid values are AzureCloud, AzureChinaCloud, AzureUSGovernment. Required only if ARMAccessToken is used.
    .PARAMETER Region
        Specifies the Region to create the resource. Region is a Mandatory parameter.
    .PARAMETER ArmAccessToken
         Specifies the ARM access token. Specifying this along with AccountId will avoid Azure interactive logon. If not specified, Azure Context is expected to be setup.
    .PARAMETER AccountID 
         Specifies the Account Id. Specifying this along with ArmAccessToken will avoid Azure interactive logon. Required only if ARMAccessToken is used.
    .PARAMETER SpnCredential
        Specifies the Service Principal Credential. Required only if ARMAccessToken is not used.
    .PARAMETER Tag
        Specifies the resource tags for the resource in Azure in the form of key-value pairs in a hash table. For example: @{key0="value0";key1=$null;key2="value2"}
    .PARAMETER OutputPath
         Directory path for log and report output.
    .PARAMETER Proxy
         Specify proxy server.
     #>
     [CmdletBinding(DefaultParametersetName='AZContext')]
     param (
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Subscription ID to project ARC resource ")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Subscription ID to project ARC resource ")]
         [string]
         $SubscriptionID,
         
         #TODO: should we do a validation of if the resource group is created or should we create the RG ?
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Resource group used for HCI ARC Integration")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Resource group used for HCI ARC Integration")]
         [string]
         $ResourceGroup,
         
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Tenant used for HCI ARC Integration")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Tenant used for HCI ARC Integration")]
         [string]
         $TenantID,
         
        # AzureCloud , AzureUSGovernment , AzureChinaCloud 
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Cloud type  used for HCI ARC Integration. Valid values are : AzureCloud , AzureUSGovernment , AzureChinaCloud")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Cloud type used for HCI ARC integration. Valid values are : AzureCloud , AzureUSGovernment , AzureChinaCloud")]
        [string] 
        $Cloud,
        
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Region used for HCI ARC Integration")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Region used for HCI ARC Integration")]
         [string] 
         $Region,


         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "ARM Access Token used for HCI ARC Integration")]
         [string]
         $ArmAccessToken,

         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Account ID used for HCI ARC Integration")]
         [string]
         $AccountID,
         
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "SPN credential used for onboarding AR")]
         [System.Management.Automation.PSCredential] 
         $SpnCredential,
         
         [Parameter(ParameterSetName='SPN', Mandatory=$false)]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $false, HelpMessage = "Return PSObject result.")]
         [Parameter(Mandatory = $false)]
         [System.Collections.Hashtable] $Tag,

         [Parameter(ParameterSetName='SPN', Mandatory=$false)]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $false, HelpMessage = "Directory path for log and report output")]
         [string]$OutputPath,
         
         [Parameter(ParameterSetName='SPN', Mandatory=$false, HelpMessage = "Specify proxy server.")]
         [Parameter(ParameterSetName='ARMToken', Mandatory=$false, HelpMessage = "Specify proxy server.")]
         [string]
         $Proxy,

         [Parameter(Mandatory = $false)]
         [Switch] $Force

         
     )
 
     try
     {

        $script:ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        Set-AzStackHciOutputPath -Path $OutputPath
        Log-Info -Message "Installing and Running Azure Stack HCI Environment Checker" -ConsoleOut
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
        $environmentValidatorResult = RunEnvironmentValidator
        if ($environmentValidatorResult -ne [ErrorDetail]::Success -and (-Not $Force) ) {
            Log-Info -Message "Environment Validator failed so not installing the ARC agent" -Type Error -ConsoleOut
            throw "Environment Validator failed, so skipping ARC integration"
        }
        install-HypervModules -SkipErrors $Force

        Log-Info -Message "Starting AzStackHci ArcIntegration Initialization" -ConsoleOut  
        $scrubbedParams = @{}
        foreach($psbp in $PSBoundParameters.GetEnumerator())
        {
            if($psbp.Key -eq "ArmAccessToken")
            {
                continue
            }
            $scrubbedParams[$psbp.Key] = $psbp.Value
        }

        Write-AzStackHciHeader -invocation $MyInvocation -params $scrubbedParams -PassThru:$PassThru

        $ArcConnectionState = Check-NodeArcRegistrationStateScriptBlock

        #TODO: other validations related to OS Type and Version should happen here.
        # If the agent is already installed and not connected, we will re-install the agent again. This is like upgrade operation
        & "$PSScriptRoot\Classes\install_aszmagent_hci.ps1" -AltDownload "https://download.microsoft.com/download/5/e/9/5e9081ed-2ee2-4b3a-afca-a8d81425bcce/AzureConnectedMachineAgent.msi";
        if ($LASTEXITCODE -ne 0) { exit 1; }

        # Run connect command
        $CorrelationID =  New-Guid
        $machineName = [System.Net.Dns]::GetHostName()
        if (-not [string]::IsNullOrEmpty($Proxy))
        {
            Log-Info -Message "Configuring proxy on agent : $($Proxy)" -ConsoleOut
            & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set proxy.url $Proxy ;
        }

        if ($PSCmdlet.ParameterSetName -eq "SPN")
        {
            Log-Info -Message "Connecting to Azure using SPN Credentials" -ConsoleOut
            Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $SpnCredential | out-null

            Log-Info -Message "Connected to Azure successfully" -ConsoleOut

            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.HybridCompute"
            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.GuestConfiguration"
            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.HybridConnectivity"
            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.AzureStackHCI"
            if ($ArcConnectionState -ne [ErrorDetail]::NodeAlreadyArcEnabled) {
                Log-Info -Message "Connecting to Azure ARC agent " -ConsoleOut

                & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$SpnCredential.UserName" --service-principal-secret "$SpnCredential.GetNetworkCredential().Password" --resource-group "$ResourceGroup"  --resource-name "$machineName"  --tenant-id "$TenantID" --location "$Region" --subscription-id "$SubscriptionID" --cloud "$Cloud" --correlation-id "$CorrelationID"; 

                if ($LASTEXITCODE -ne 0) {
                    Log-Info -Message "Azure ARC agent onboarding failed " -ConsoleOut
                    throw "Arc agent onboarding failed, so erroring out, logs are present in C:\ProgramData\AzureConnectedMachineAgent\Log\azcmagent.log"
                }

                Log-Info -Message "Connected Azure ARC agent successfully " -ConsoleOut
            }
            else {
                Log-Info -Message "Node Already Arc Enabled, so skipping the arc registration" -ConsoleOut
            }

            PerformRoleAssignmentsOnArcMSI $ResourceGroup
               
        }
        elseif ($PSCmdlet.ParameterSetName -eq "ARMToken")
        {
            Log-Info -Message "Connecting to Azure using ARM Access Token" -ConsoleOut

            Connect-AzAccount -Environment $Cloud -Tenant $TenantID  -AccessToken $ArmAccessToken -AccountId $AccountId -Subscription $SubscriptionID | out-null

            Log-Info -Message "Connected to Azure successfully" -ConsoleOut

            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.HybridCompute"
            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.GuestConfiguration"
            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.HybridConnectivity"
            Register-ResourceProviderIfRequired -ProviderNamespace "Microsoft.AzureStackHCI"
            
            if ($ArcConnectionState -ne [ErrorDetail]::NodeAlreadyArcEnabled) {
                & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --resource-group "$ResourceGroup" --resource-name "$machineName" --tenant-id "$TenantID" --location "$Region" --subscription-id "$SubscriptionID" --cloud "$Cloud" --correlation-id "$CorrelationID" --access-token "$ArmAccessToken";
            
                if ($LASTEXITCODE -ne 0) {
                    Log-Info -Message "Azure ARC agent onboarding failed " -ConsoleOut
                    throw "Arc agent onboarding failed, so erroring out, logs are present in C:\ProgramData\AzureConnectedMachineAgent\Log\azcmagent.log" 
                }

                Log-Info -Message "Connected Azure ARC agent successfully " -ConsoleOut
            }
            else {
                Log-Info -Message "Node is already arc enabled so skipping ARC registration" -ConsoleOut
            }

            PerformRoleAssignmentsOnArcMSI $ResourceGroup
        }

        Log-Info -Message "Installing  TelemetryAndDiagnostics Extension " -ConsoleOut

        $Settings = @{ "CloudName" = $Cloud; "RegionName" = $Region; "DeviceType" = "AzureEdge" }
        New-AzConnectedMachineExtension -Name "TelemetryAndDiagnostics"  -ResourceGroupName $ResourceGroup -MachineName $env:COMPUTERNAME -Location $Region -Publisher "Microsoft.AzureStack.Observability" -Settings $Settings -ExtensionType "TelemetryAndDiagnostics" -NoWait | out-null

        Log-Info -Message "Successfully triggered  TelemetryAndDiagnostics Extension installation " -ConsoleOut
        Start-Sleep -Seconds 60

        Log-Info -Message "Installing  DeviceManagement Extension " -ConsoleOut
        New-AzConnectedMachineExtension -Name "AzureEdgeDeviceManagement"  -ResourceGroupName $ResourceGroup -MachineName $env:COMPUTERNAME -Location $Region -Publisher "Microsoft.Edge" -ExtensionType "DeviceManagementExtension" -NoWait | out-null

        Log-Info -Message "Successfully triggered  DeviceManagementExtension installation " -ConsoleOut
        Start-Sleep -Seconds 60

        Log-Info -Message "Installing LcmController Extension " -ConsoleOut
        New-AzConnectedMachineExtension -Name "AzureEdgeLifecycleManager"  -ResourceGroupName $ResourceGroup -MachineName $env:COMPUTERNAME -Location $Region -Publisher "Microsoft.AzureStack.Orchestration" -ExtensionType "LcmController" -NoWait | out-null 

        Log-Info -Message "Successfully triggered  LCMController Extension installation " -ConsoleOut
        Start-Sleep -Seconds 60

        Log-Info -Message "Installing EdgeRemoteSupport Extension " -ConsoleOut
        New-AzConnectedMachineExtension -Name "EdgeRemoteSupport"  -ResourceGroupName $ResourceGroup -MachineName $env:COMPUTERNAME -Location $Region -Publisher "Microsoft.AzureStack.Observability" -ExtensionType "EdgeRemoteSupport" -NoWait | out-null

        Log-Info -Message "Successfully triggered  EdgeRemoteSupport Extension installation " -ConsoleOut

        Log-Info -Message "Please verify that the extensions are successfully installed before continuing..." -ConsoleOut
     }
     catch
     {
         Log-Info -Message "" -ConsoleOut
         Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
         Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
         $cmdletFailed = $true
         throw $_
     }
     finally
     {
        Disconnect-AzAccount -ErrorAction SilentlyContinue | out-null
        $Script:ErrorActionPreference = 'SilentlyContinue'
        Write-AzStackHciFooter -invocation $MyInvocation -Failed:$cmdletFailed -PassThru:$PassThru
        $Script:ErrorActionPreference = 'Stop'
     }
 }


 function Remove-AzStackHciArcInitialization
 {
     <#
     .SYNOPSIS
         Perform AzStackHci ArcIntegration Initialization
     .DESCRIPTION
         Initializes ARC integration on Azure Stack HCI node
     .EXAMPLE
         PS C:\> Connect-AzAccount -Tenant $tenantID -Subscription $subscriptionID -DeviceCode
         PS C:\>  $nodeNames = [string[]]("host1","host2","host3","host4")
         PS C:\>  Invoke-AzStackHciArcIntegrationValidation -SubscriptionID $subscriptionID -ArcResourceGroupName $resourceGroupName -NodeNames $nodeNames
     .PARAMETER SubscriptionID
         Specifies the Azure Subscription to create the resource. Is Mandatory Paratmer
     .PARAMETER ResourceGroup
        TODO: This is not used anywhere. Remove it
     .PARAMETER TenantID
         Specifies the Azure TenantId.Required only if ARMAccessToken is used.
     .PARAMETER Cloud
         Specifies the Azure Environment. Valid values are AzureCloud, AzureChinaCloud, AzureUSGovernment. Required only if ARMAccessToken is used.
     .PARAMETER ArmAccessToken
         Specifies the ARM access token. Specifying this along with AccountId will avoid Azure interactive logon. If not specified, Azure Context is expected to be setup.
     .PARAMETER AccountID 
         Specifies the Account Id. Specifying this along with ArmAccessToken will avoid Azure interactive logon. Required only if ARMAccessToken is used.
     
    .PARAMETER PassThru
         Return PSObject result.
     .PARAMETER OutputPath
         Directory path for log and report output.
     .PARAMETER CleanReport
         Remove all previous progress and create a clean report.
     .INPUTS
         Inputs (if any)
     .OUTPUTS
         Output (if any)
     #>
     [CmdletBinding(DefaultParametersetName='AZContext')]
     param (
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Environment used for HCI ARC Integration")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Environment used for HCI ARC Integration")]
         [string]
         $SubscriptionID,
         
         #TODO: should we do a validation of if the resource group is created or should we create the RG ?
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Environment used for HCI ARC Integration")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Tenant used for HCI ARC Integration")]
         [string]
         $ResourceGroup,
         
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Azure Environment used for HCI ARC Integration")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Azure Subscription used for HCI ARC Integration")]
         [string]
         $TenantID,
         # AzureCloud , AzureUSGovernment , AzureChinaCloud 
         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "Specifies the Azure Environment. Azure Valid values are AzureCloud, AzureChinaCloud, AzureUSGovernment")]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Specifies the Azure Environment. Azure Valid values are AzureCloud, AzureChinaCloud, AzureUSGovernment")]
         [string] 
         $Cloud,

         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "ARM Access Token used for HCI ARC Integration")]
         [string]
         $ArmAccessToken,

         [Parameter(ParameterSetName='ARMToken', Mandatory = $true, HelpMessage = "Account ID used for HCI ARC Integration")]
         [string]
         $AccountID,
         

         [Parameter(ParameterSetName='SPN', Mandatory = $true, HelpMessage = "SPN credential used for onboarding ARC machine")]
         [System.Management.Automation.PSCredential] 
         $SpnCredential,

        [Parameter(ParameterSetName='SPN', Mandatory=$false)]
        [Parameter(ParameterSetName='ARMToken', Mandatory = $false, HelpMessage = "Use to force clean the device , even if the cloud side clean up fails")]
        [switch]
        $Force,
 
         [Parameter(ParameterSetName='SPN', Mandatory=$false)]
         [Parameter(ParameterSetName='ARMToken', Mandatory = $false, HelpMessage = "Directory path for log and report output")]
         [string]$OutputPath
     )
 
     try
     {
        $script:ErrorActionPreference = 'Stop'
        Set-AzStackHciOutputPath -Path $OutputPath
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

        Log-Info -Message "Starting Arc Cleanup" -ConsoleOut

        $ArcConnectionState = Check-NodeArcRegistrationStateScriptBlock

        if ($PSCmdlet.ParameterSetName -eq "SPN")
        {
            Log-info -Message "Connecting to Azure with SPN" -ConsoleOut
            Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $SpnCredential
            RemoveRoleAssignmentsOnArcMSI $ResourceGroup
            Log-info -Message "Successfully connected to Azure with SPN" -ConsoleOut
            if ($ArcConnectionState -eq [ErrorDetail]::NodeAlreadyArcEnabled) {
                try {
                    Log-Info -Message "Removing Arc Extensions" -ConsoleOut
                    #TODO: enable Debug logs on Azure cmdlets
                    Get-AzConnectedMachineExtension -ResourceGroupName  $ResourceGroup -MachineName $ENV:COMPUTERNAME | Remove-AzConnectedMachineExtension -NoWait
                
                    Log-Info -Message "Removed Arc Extensions successfully" -ConsoleOut
                
                    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" disconnect --service-principal-id "$SpnCredential.UserName" --service-principal-secret "$SpnCredential.GetNetworkCredential().Password" ;

                    Log-Info -Message "successfully disconnected ARC agent" -ConsoleOut

                }
                catch {
                    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" disconnect --force-local-only;
                    #TODO: delete all the extension folders
                }
            }
            else{
                Log-Info -Message "Node was not ARC enabled so not disconnecting from ARC" -ConsoleOut
            }
  
        }
        elseif ($PSCmdlet.ParameterSetName -eq "ARMToken")
        {
            Log-Info -Message "Connecting to Azure with ARMAccess Token" -ConsoleOut
            Connect-AzAccount -Environment $Cloud -Tenant $TenantID  -AccessToken $ArmAccessToken -AccountId $AccountId -Subscription $SubscriptionID | out-null
            RemoveRoleAssignmentsOnArcMSI $ResourceGroup
            Log-Info -Message "Successfully connected to Azure with ARM Token" -ConsoleOut
            if ($ArcConnectionState -eq [ErrorDetail]::NodeAlreadyArcEnabled) {
                try {
                
                    Log-Info -Message "Removing Arc Extensions" -ConsoleOut
                    Get-AzConnectedMachineExtension -ResourceGroupName  $ResourceGroup -MachineName $ENV:COMPUTERNAME | Remove-AzConnectedMachineExtension -NoWait
            
                    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" disconnect  --access-token "$ArmAccessToken";
                
                    Log-Info -Message "successfully disconnected ARC agent" -ConsoleOut
                
                }
                catch {
                    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" disconnect --force-local-only;
                    #TODO: delete all the extension folders
                }
            }
            else{
                Log-Info -Message "Node was not ARC enabled, so not removing ARC agent" -ConsoleOut
            }

        }

     }
     catch
     {
         Log-Info -Message "" -ConsoleOut
         Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
         Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
         $cmdletFailed = $true
         throw $_
     }
     finally
     {
         Disconnect-AzAccount -ErrorAction SilentlyContinue | out-null
         $Script:ErrorActionPreference = 'SilentlyContinue'
     }
 }

 # Method to assign role assignments on ARC MSI
function PerformRoleAssignmentsOnArcMSI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup
    )
    try {
        $objectId = GetObjectIdFromArcMachine
        if ($null -ne $objectId) {
            $setEdgeDevicesRolesResult = AssignRoleToAnObjectUsingRetries -ObjectId $objectId -RoleName "Azure Stack HCI Device Management Role" -ResourceGroup $ResourceGroup -Verbose
            if ($setEdgeDevicesRolesResult -ne [ErrorDetail]::Success) {
                Log-Info -Message "Failed to assign Edge devices create role on the resource group" -ConsoleOut -Type Error
            }
            else{
                Log-Info -Message "Successfully assigned permission Azure Stack HCI Device Management Service Role to create or update Edge Devices on the resource group" -ConsoleOut
            }
            
            # Temporary assignment till the Observability role removes the extension installation call
            $arcManagerRoleStatus = AssignRoleToAnObjectUsingRetries -ObjectId $objectId -RoleName "Azure Connected Machine Resource Manager" -ResourceGroup $ResourceGroup
            if ($arcManagerRoleStatus -ne [ErrorDetail]::Success) {
                Log-Info -Message "Failed to assign the Azure Connected Machine Resource Manager role on the resource group" -ConsoleOut -Type Error
            }
            else{
                Log-Info -Message "Successfully assigned the Azure Connected Machine Resource Manager role on the resource group" -ConsoleOut
            }
            # Temporary assignment till the "Azure Stack HCI Device Management Role" gets the ResourceGroup Read permission
            $readerRoleStatus = AssignRoleToAnObjectUsingRetries -ObjectId $objectId -RoleName "Reader" -ResourceGroup $ResourceGroup
            if ($readerRoleStatus -ne [ErrorDetail]::Success) {
                Log-Info -Message "Failed to assign the reader role on the resource group" -ConsoleOut -Type Error
            }
            else{
                Log-Info -Message "Successfully assigned the reader Resource Nanager role on the resource group" -ConsoleOut
            }
        }    
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}

# Method to remove role assignments on ARC MSI
function RemoveRoleAssignmentsOnArcMSI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceGroup
    )
    try {
        $objectId = GetObjectIdFromArcMachine
        if ($null -ne $objectId) {
            $edgeDevicesRoleAssignment = Get-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName "Azure Stack HCI Device Management Service Role" -ResourceGroupName $ResourceGroup
            if ($null -ne $edgeDevicesRoleAssignment){
                Remove-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName "Azure Stack HCI Device Management Service Role" -ResourceGroupName $ResourceGroup
                Log-Info -Message "Successfully removed permission Azure Stack HCI Device Management Service Role to create or update Edge Devices on the resource group" -ConsoleOut
            }
            else{
                Log-Info -Message "Already Azure Stack HCI Device Management Service Role role assignment is removed" -ConsoleOut
            }
        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
}

# Set Role On An Object Id with retries
function AssignRoleToAnObjectUsingRetries {
    param(
        [String] $ObjectId,
        [String] $ResourceGroup,
        [string] $RoleName
    )
    $stopLoop = $false
    [int]$retryCount = "0"
    [int]$maxRetryCount = "5"

    Log-Info -Message $"Checking if $RoleName is assigned already for SPN with Object ID: $ObjectId" -ConsoleOut
    $arcSPNRbacRoles = Get-AzRoleAssignment -ObjectId $ObjectId -ResourceGroupName $ResourceGroup
    $alreadyFoundRole = $false
    $arcSPNRbacRoles | ForEach-Object {
        $roleFound = $_.RoleDefinitionName
        if ($roleFound -eq $RoleName)
        {
            $alreadyFoundRole=$true
            Log-Info -Message $"Already Found $RoleName Not Assigning" -ConsoleOut
        }
    }
    if( -not $alreadyFoundRole)
    {
        Log-Info -Message "Assigning $RoleName to Object : $ObjectId" -ConsoleOut
        do
        {
            try
            {
                New-AzRoleAssignment -ObjectId $ObjectId -ResourceGroupName $ResourceGroup -RoleDefinitionName $RoleName | Out-Null
                Log-Info -Message $"Sucessfully assigned $RoleName to Object Id $ObjectId" -ConsoleOut
                $stopLoop = $true
            }
            catch
            {
                # 'Conflict' can happen when either the RoleAssignment already exists or the limit for number of role assignments has been reached.
                if ($_.Exception.Response.StatusCode -eq 'Conflict')
                {
                    $roleAssignment  = Get-AzRoleAssignment -ObjectId $ObjectId -ResourceGroupName $ResourceGroup -RoleDefinitionName $RoleName
                    if ($null -ne $roleAssignment)
                    {
                        Log-Info -Message $"Sucessfully assigned $RoleName to Object Id $ObjectId" -ConsoleOut
                        return [ErrorDetail]::Success
                    }
                    Log-Info -Message $"Failed to assign roles to service principal with object Id $($ObjectId). ErrorMessage: " + $_.Exception.Message + " PositionalMessage: " + $_.InvocationInfo.PositionMessage -ConsoleOut -Type Error
                    return [ErrorDetail]::PermissionsMissing
                }
                if ($retryCount -ge $maxRetryCount)
                {
                    # Timed out.
                    Log-Info -Message $"Failed to assign roles to service principal with object Id $($ObjectId). ErrorMessage: " + $_.Exception.Message + " PositionalMessage: " + $_.InvocationInfo.PositionMessage -ConsoleOut -Type Error
                    return [ErrorDetail]::PermissionsMissing
                }
                Log-Info -Message $"Could not assign roles to service principal with Object Id $($ObjectId). Retrying in 10 seconds..." -ConsoleOut
                Start-Sleep -Seconds 10
                $retryCount = $retryCount + 1
            }
        }
        While(-Not $stopLoop)
    }
    return [ErrorDetail]::Success
}

function install-HypervModules{
    param
    (
        [bool] $SkipErrors
    )

    $status = Get-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V
    if ($status.State -ne "Enabled") {
        if($SkipErrors)
        {
            Log-Info -Message "Hyper-v feature is not enabled. Continuing since 'Force' is configured." -ConsoleOut
        }
        else
        {
            throw "Windows Feature 'Microsoft-Hyper-V' is not enabled. Cannot proceed."                
        }
    }
    if (($state.RestartRequired -eq "Possible") -or ($state.RestartRequired -eq "Required"))
    {
        if($SkipErrors)
        {
            Log-Info -Message "Hyper-v feature requires a node restart, please restart the node using Restart-Computer -Force" -ConsoleOut
        }
        else
        {
            throw "Windows Feature 'Microsoft-Hyper-V' requires a node restart to be enabled. Please run Restart-Computer -Force"                
        }
    }  
    try
    {
        Log-Info -Message "Installing Hyper-V Management Tools" -ConsoleOut
        Install-WindowsFeature -Name Hyper-V -IncludeManagementTools | Out-Null
        Log-Info -Message "Successfully installed Hyper-V Management Tools"                
    }
    catch
    {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
 }
 # Method to Get the object id from the ARC Imds endpoint
 function GetObjectIdFromArcMachine {
    try {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("metadata", "true")
        $headers.Add("UseDefaultCredentials","true")
        $response = Invoke-WebRequest -Uri "http://localhost:40342/metadata/instance/compute?api-version=2020-06-01" -Method GET -Headers $headers -UseBasicParsing
        $content = $response.Content | ConvertFrom-Json
        Log-Info -Message "Successfully got the content from IMDS endpoint" -ConsoleOut
        $arcResource = Get-AzResource -ResourceId $content.resourceId
        $objectId = $arcResource.Identity.PrincipalId
        Log-Info -Message "Successfully got Object Id for Arc Installation $objectId" -ConsoleOut
        return $objectId
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
    }
    
 }

 function RunEnvironmentValidator {
    try {
        Install-Module -Name AzStackHci.EnvironmentChecker -Repository PSGallery -Force -AllowClobber
        $res = Invoke-AzStackHciConnectivityValidation -PassThru
        $successfulTests = $res | Where-Object { $_.Status -eq "Succeeded"}
        if ($res.Count -eq $successfulTests.Count){
            Log-Info -Message "All the environment validation checks succeeded" -ConsoleOut
            return [ErrorDetail]::Success
        }
        else {
            $failedTests = $res | Where-Object { $_.Status -ne "Succeeded"}
            $criticalFailedTests =  $failedTests | Where-Object { $_.Severity -eq "Critical"}
            if( $criticalFailedTests.Count -gt 0)
            {
                Log-Info -Message "Critical environment validations failed, Failed Tests are shown below" -ConsoleOut
                $criticalFailedTests | Where-Object { $msg = $_ | Format-List | Out-String ; Log-Info -Message $msg -ConsoleOut }
                return [ErrorDetail]::EnvironmentValidationFailed
                
            }else
            {
                Log-Info -Message "Non-Critical environment validations failed, Failed Tests are shown below" -ConsoleOut
                $failedTests | Where-Object { $msg = $_ | Format-List | Out-String ; Log-Info -Message $msg -ConsoleOut }
                return [ErrorDetail]::Success
            }

        }
    }
    catch {
        Log-Info -Message "" -ConsoleOut
        Log-Info -Message "$($_.Exception.Message)" -ConsoleOut -Type Error
        Log-Info -Message "$($_.ScriptStackTrace)" -ConsoleOut -Type Error
        return [ErrorDetail]::EnvironmentValidationFailed
    }
    return [ErrorDetail]::EnvironmentValidationFailed
 }
enum ErrorDetail
{
    Unused;
    PermissionsMissing;
    Success;
    NodeAlreadyArcEnabled;
    EnvironmentValidationFailed
}

Export-ModuleMember -Function Invoke-AzStackHciArcInitialization
Export-ModuleMember -Function Remove-AzStackHciArcInitialization