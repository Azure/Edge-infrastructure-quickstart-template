param(
    $userName,
    $password,
    $ip, $port,
    $subId, $resourceGroupName, $region, $tenant, $servicePrincipalId, $servicePrincipalSecret, $expandC
)

$script:ErrorActionPreference = 'Stop'
echo "Hello!"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secpasswd
$session = New-PSSession -ComputerName $ip -Port $port -Authentication Credssp -Credential $cred


Invoke-Command -Session $session -ScriptBlock {
    if (Test-Path c:\arc-installer) {
        rm c:\arc-installer -r
    }
}

Copy-Item -ToSession $session "$PSScriptRoot\arc-installer" -Destination "c:\arc-installer" -Recurse

Invoke-Command -Session $session -ScriptBlock {
    Param ($subId, $resourceGroupName, $region, $tenant, $servicePrincipalId, $servicePrincipalSecret)
    $script:ErrorActionPreference = 'Stop'
    cd c:\arc-installer
    set-executionpolicy Bypass -force
    function Install-ModuleIfMissing {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Name,
            [string]$Repository = 'PSGallery',
            [switch]$Force
        )
        $script:ErrorActionPreference = 'Stop'
        $module = Get-Module -Name $Name -ListAvailable
        if (!$module) {
            Write-Host "Installing module $Name"
            Install-Module -Name $Name -Repository $Repository -Force:$Force
        }
    }

    if ($expandC) {
        # Expand C volume as much as possible
        $drive_letter = "C"
        $size = (Get-PartitionSupportedSize -DriveLetter $drive_letter)
        if ($size.SizeMax -gt (Get-Partition -DriveLetter $drive_letter).Size) {
            echo "Resizing volume"
            Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax
        }
    }

    echo "Validate BITS is working"
    $job = Start-BitsTransfer -Source https://aka.ms -Destination $env:TEMP -TransferType Download -Asynchronous
    $count = 0
    while ($job.JobState -ne "Transferred" -and $count -lt 30) {
        if ($job.JobState -eq "TransientError"){
            throw "BITS transfer failed"
        }
        sleep 6
        $count++
    }
    if ($count -ge 30) {
        throw "BITS transfer failed after 3 minutes. Job state: $job.JobState"
    }

    $creds = [System.Management.Automation.PSCredential]::new($servicePrincipalId, (ConvertTo-SecureString $servicePrincipalSecret -AsPlainText -Force))

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false

    Install-ModuleIfMissing -Name Az -Repository PSGallery -Force

    Connect-AzAccount -Subscription $subId -Tenant $tenant -Credential $creds -ServicePrincipal
    echo "login to Azure"

    Import-Module .\AzSHCI.ARCInstaller.psm1 -Force
    Install-ModuleIfMissing Az.Accounts -Force
    Install-ModuleIfMissing Az.ConnectedMachine -Force
    Install-ModuleIfMissing Az.Resources -Force
    echo "Installed modules"
    $id = (Get-AzContext).Tenant.Id
    $token = (Get-AzAccessToken).Token
    $accountid = (Get-AzContext).Account.Id
    Invoke-AzStackHciArcInitialization -SubscriptionID $subId -ResourceGroup $resourceGroupName -TenantID $id -Region $region -Cloud "AzureCloud" -ArmAccessToken $token -AccountID  $accountid
} -ArgumentList $subId, $resourceGroupName, $region, $tenant, $servicePrincipalId, $servicePrincipalSecret
