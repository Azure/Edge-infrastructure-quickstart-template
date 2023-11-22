[CmdletBinding()]
param (
    [string]$OutFile,
    [string]$AltDownload,
    [string]$Proxy,
    [string]$AltHisEndpoint    
)


$refVersion = [version] '4.5'
$provider = 'Microsoft.HybridCompute'

# Error codes used by azcmagent are in range of [0, 125].
# Installation scripts will use [127, 255]. Check install_linux_azcmagent.sh for the codes used for Linux script.
$global:errorcode="AZCM0150"

#Check if PowerShell is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Log-Info -Message "This script must be run as an administrator." -ConsoleOut -Type Error
}

# Ensure TLS 1.2 is accepted. Older PowerShell builds (sometimes) complain about the enum "Tls12" so we use the underlying value
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
# Ensure TLS 1.3 is accepted, if this .NET supports it (older versions don't)
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 12288 } catch {}

function Test-AzureStackHCI() {
    [CmdletBinding()]
    param (
    )

    try {
        $product=Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName | select -ExpandProperty ProductName
    }
    catch {
        Log-Info -Message "Error $_ Unable to determine product SKU from registry" -ConsoleOut -Type Info
        # Will attempt to install anyway
        return $false
    }
    if ($product -eq 'Azure Stack HCI') {
        return $true
    }
    return $false
}

function Test-PowerShellVersion() {
    [CmdletBinding()]
    param (
    )

    Log-Info -Message "PowerShell version: $($PSVersionTable.PSVersion)" -ConsoleOut -Type Info
    return ($PSVersionTable.PSVersion -ge [Version]"3.0")
}

function Test-DotNetFramework() {
    [CmdletBinding()]
    param (
    )

    try {
        $installedVersion = [version] (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Version | select -ExpandProperty Version)
    }
    catch {
        Log-Info -Message "Error $_ Unable to determine .NET Framework version" -ConsoleOut -Type Info
        # Will attempt to install anyway
        return $true
    }
    Log-Info -Message ".NET Framework version: $installedVersion" -ConsoleOut -Type Info
    if ($installedVersion -ge $refVersion) {
        return $true
    }
    return $false
}



function Get-MsiLogSummary() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$LogPath
    )

    try
    {
        $LogPath = Resolve-Path $LogPath
        Log-Info -Message "Reading Logs from $LogPath" -ConsoleOut -Type Info
        $patterns = @(
            "Installation success or error status",
            "Product: Azure Connected Machine Agent"
        );

        $regex = "(" + ($patterns -join ")|(" ) + ")"

        Write-Verbose "Looking for Patterns: $regex"
        Log-Info -Message "Looking for Patterns: $regex" -ConsoleOut -Type Info

        $inCustomAction = $false
        $logCustomAction = $false
        $caOutput = new-object -TypeName System.Collections.ArrayList
        Get-Content $LogPath | % {
            # log interesting lines
            if ( ($_ -match $regex)) {
                $_ # output to pipeline
            }

            # Wix custom actions start with "Calling custom Action". Gather the log from the CA till we see if it passed
            # At the end, log that output only if it failed with "returned actual error"
            if ($_ -match "Calling custom action") {
                $inCustomAction = $true
                $logCustomAction = $false
            }
            if ($_ -match "MSI \(s\)") {
                $inCustomAction = $false 
            }
            if ($_ -match "returned actual error") {
                $logCustomAction = $true
            }
            if ($inCustomAction) {
                $null = $caOutput.Add($_)
            }
            else
            {
                if($logCustomAction) {
                    $caOutput # output saved lines to pipeline
                }
                $caOutput.Clear()
            }
        }
    } catch {
        # This code is optional so if something goes wrong we'll just swallow the error and have no details
        Log-Info -Message "Error while parsing MSI log: $_" -ConsoleOut -Type Info
    }
}

<# Throw a structured exception#>
function Invoke-Failure
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Message,
        [Parameter(Mandatory=$true)]
        $ErrorCode,
        [Parameter(Mandatory=$false)]
        $Details
    )

    $ex = new-object -TypeName System.Exception -ArgumentList @($Message)
    $ex.Data["Details"] = $details
    $ex.Data["ErrorCode"] = $errorcode
    throw $ex
}

function Send-Failure
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Exception] $Error,

        [Parameter(Mandatory = $true)]
        [string] $ErrorCode,

        [Parameter(Mandatory = $false)]
        [string] $AltHisEndpoint

    )

    $hisEndpoint = "https://gbl.his.arc.azure.com"
    if ($env:CLOUD -eq "AzureUSGovernment") {
        $hisEndpoint = "https://gbl.his.arc.azure.us"
    } elseif ($env:CLOUD -eq "AzureChinaCloud") {
        $hisEndpoint = "https://gbl.his.arc.azure.cn"
    } elseif ($env:CLOUD -eq "AzureStackCloud") {
        if ($AltHisEndpoint) {
            $hisEndpoint = $AltHisEndpoint
        }
        else {
            Log-Info -Message "error in Send-Failure due to invalid his endpoint." -ConsoleOut -Type Warning
            return
        }
    }

    $message = "$Error"
    if ($Error.Data["Details"]) {
        $message = $Error.Data["Details"]
    }
    $message = $message.Substring(0, [Math]::Min($message.Length, 600))

    if ( $env:PROVIDER_NAMESPACE ) {
        $provider = $env:PROVIDER_NAMESPACE
    }
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";namespace="$provider";osType="windows";messageType="$ErrorCode";message="$message";}
    
    Invoke-WebRequest -UseBasicParsing -Uri "$hisEndpoint/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) -ErrorAction SilentlyContinue | out-null
}

# Based on the MSI error code, we may have some hint to provide as to the issue
# See https://learn.microsoft.com/en-us/windows/win32/msi/error-codes
function Get-MsiErrorDetails() {
    [CmdletBinding()]
    param(
        $exitCode
    )

    $message = (net helpmsg $exitCode) -join ""
    $hint = ""
    $errorCode = "AZCM0149" # exitCode is the return value from msiexec. errorCode is the error code of the script
    switch($exitCode) {
        1633 {
            # ERROR_INSTALL_PLATFORM_UNSUPPORTED 
            $hint = "Unsupported: Azure Connected Machine Agent is only compatible with X64 operating systems"
            $errorCode = "AZCM0153"
        }
    }
    return [PSCustomObject]@{
        Message = $message
        Hint = $hint
        ErrorCode = $errorCode
    }
}

function Check-Physical-Memory() {
    [CmdletBinding()]
    param (
    )

    $memory = systeminfo | Select-String '^Total Physical Memory'
    Log-Info -Message "$memory" -ConsoleOut -Type Info
}

try {
    Log-Info -Message "Installing Azure Connected Machine Agent" -ConsoleOut -Type Info
    Check-Physical-Memory
    
    #TODO: need to uncomment this after local testing
    # $hci = Test-AzureStackHCI
    # if (-not $hci) 
    # {
    #     Invoke-Failure -Message "This server is NOT running Azure Stack HCI , this module is only meant for Azure Stack HCI servers" -ErrorCode "AZCM0152"
    # }

    $validPowerShell = Test-PowerShellVersion
    if (-Not $validPowerShell) 
    {
        Invoke-Failure -Message "Azure Connected Machine Agent requires PowerShell version 4.0 or later" -ErrorCode "AZCM0154"
    }

    $validFramework = Test-DotNetFramework
    if (-Not $validFramework) 
    {
        Invoke-Failure -Message "Azure Connected Machine Agent requires .NET Framework version $refVersion or later" -ErrorCode "AZCM0151"
    }
    
    # Download the package
    $msiFile = Join-Path $env:Temp "AzureConnectedMachineAgent.msi"
        
    try {
        if ($AltDownload) {
            $downloadUri = $AltDownload
        }
        else {
            $downloadUri = "https://aka.ms/AzureConnectedMachineAgent" 
        }

        if (([Uri]$downloadUri).Scheme -in @("https","http"))
        {
            Log-Info -Message "Downloading agent package from $downloadUri to $msiFile" -ConsoleOut -Type Info
            # It's a web site, download it
            if ($Proxy) {
                Invoke-WebRequest -UseBasicParsing -Proxy $Proxy -Uri $downloadUri -OutFile $msiFile
            } else {
                Invoke-WebRequest -UseBasicParsing -Uri $downloadUri -OutFile $msiFile
            }
        }
        else {
            # This could be a UNC path or a local file, just try and copy it
            Log-info -Message "Copying agent package from $downloadUri to $msiFile" -ConsoleOut -Type Info
            Copy-Item $downloadUri $msiFile
        }
	} 
    catch {
        Invoke-Failure -ErrorCode "AZCM0148" -Message "Download failed: $_"
    }
        
    # Install the package
    $logFile = Join-Path $env:Temp "installationlog.txt"
    Log-Info -Message "Installing agent package" -ConsoleOut -Type Info
    $exitCode = (Start-Process -FilePath msiexec.exe -ArgumentList @("/i", $msiFile , "/l*v", $logFile, "/qn") -Wait -Passthru).ExitCode
    if ($exitCode -ne 0) {
        $details = (Get-MsiErrorDetails $exitCode)
        $logInfo = ((Get-MsiLogSummary $logFile) -join "`n")
        Invoke-Failure -Message "Installation failed: [$exitCode]: $($details.Message) $($details.Hint)`: See $logFile for additional details." -ErrorCode $details.ErrorCode -Details $logInfo
    }

    # Check if we need to set proxy environment variable
    if ($Proxy) {
        Log-Info -Message "Setting proxy configuration: $Proxy" -ConsoleOut -Type Info 
        & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent" config set proxy.url ${Proxy}
    }
    
} catch {
    $code = $_.Exception.Data.ErrorCode
    $details = $_.Exception.Data.Details
    if(!$code) { $code = "AZCM0150" } # default if we do not have some more specific error 
    if ($OutFile) {
        [ordered]@{
            status  = "failed"
            error = [ordered]@{
                message = $_.Exception.Message
                code = $code
                details = $details
            }
        } | ConvertTo-Json | Out-File $OutFile
    }
    Log-Info -Message "Installation failed: $_" -ConsoleOut -Type Error

    if ($details) {
        Write-Output "Details: $details"
    }
    Send-Failure $_.Exception $code $AltHisEndpoint
    return 1
}

# Installation was successful if we got this far
if ($OutFile) {
    [ordered]@{
        status  = "success"
        message = "Installation of azcmagent completed successfully"
    } | ConvertTo-Json | Out-File $OutFile
}

Log-Info -Message "Installation of azcmagent completed successfully" -ConsoleOut
return 0
