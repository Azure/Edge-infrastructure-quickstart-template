param(
    $userName,
    $password,
    $authType,
    $adouPath,
    $ip, $port,
    $domainFqdn,
    $ifdeleteadou,
    $deploymentUser,
    $deploymentUserPassword
)

$script:ErrorActionPreference = 'Stop'
$count = 0
        
if ($authType -eq "CredSSP") {
    try {
        echo "set trusted hosts"
        Set-Item wsman:localhost\client\trustedhosts -value $ip -Force
        echo "enable client CredSSP"
        Enable-WSManCredSSP -Role Client -DelegateComputer $ip -Force

        echo "Allow fresh credentials"
        $key = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
        if (!(Test-Path $key)) {
            md $key
        }
        New-ItemProperty -Path $key -Name AllowFreshCredentials -Value 1 -PropertyType Dword -Force            

        $allowFreshCredentialsKey = Join-Path $key 'AllowFreshCredentials'
        if (!(Test-Path $allowFreshCredentialsKey)) {
            md $allowFreshCredentialsKey
        }

        if (!(Get-ItemProperty -Path $allowFreshCredentialsKey -Name 'AzureArcIaCAutomation' -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $allowFreshCredentialsKey -Name 'AzureArcIaCAutomation' -Value 'WSMAN/*' -PropertyType String -Force
        }

        echo "Allow fresh credentials when NTLM only"
        New-ItemProperty -Path $key -Name AllowFreshCredentialsWhenNTLMOnly -Value 1 -PropertyType Dword -Force

        $allowFreshCredentialsWhenNTLMOnlyKey = Join-Path $key 'AllowFreshCredentialsWhenNTLMOnly'
        if (!(Test-Path $allowFreshCredentialsWhenNTLMOnlyKey)) {
            md $allowFreshCredentialsWhenNTLMOnlyKey
        }

        if (!(Get-ItemProperty -Path $allowFreshCredentialsWhenNTLMOnlyKey -Name 1 -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $allowFreshCredentialsWhenNTLMOnlyKey -Name 1 -Value 'WSMAN/*' -PropertyType String -Force
        }
    }
    catch {
        echo "Enable-WSManCredSSP failed"
    }
}

for ($count = 0; $count -lt 3; $count++) {
    try {
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        $domainShort = $domainFqdn.Split(".")[0]
        $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "$domainShort\$username", $secpasswd
        
        $session = New-PSSession -ComputerName $ip -Port $port -Authentication $authType -Credential $cred
        if ($ifdeleteadou) {
            Invoke-Command -Session $session -ScriptBlock {
                $OUPrefixList = @("OU=Computers,", "OU=Users,", "")
                foreach ($prefix in $OUPrefixList) {
                    $ouname = "$prefix$Using:adouPath"
                    echo "try to get OU: $ouname"
                    Try {
                        $ou = Get-ADOrganizationalUnit -Identity $ouname
                    }
                    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                        $ou = $null
                    }
                    if ($ou) {
                        Set-ADOrganizationalUnit -Identity $ouname -ProtectedFromAccidentalDeletion $false
                        $ou | Remove-ADOrganizationalUnit -Recursive -Confirm:$False 
                        echo "Deleted adou: $ouname"
                    }
                }
            }
            
        }
        $deploymentSecPasswd = ConvertTo-SecureString $deploymentUserPassword -AsPlainText -Force
        $lcmCred = New-Object System.Management.Automation.PSCredential -ArgumentList $deploymentUser, $deploymentSecPasswd
        Invoke-Command -Session $session -ScriptBlock {
            echo "Install Nuget Provider"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
            echo "Install AsHciADArtifactsPreCreationTool"
            Install-Module AsHciADArtifactsPreCreationTool -Repository PSGallery -Force -Confirm:$false
            echo "Add KdsRootKey"
            Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
            echo "New HciAdObjectsPreCreation"
            New-HciAdObjectsPreCreation -AzureStackLCMUserCredential $Using:lcmCred -AsHciOUName $Using:adouPath
        }
        break
    }
    catch {
        echo "Error in retry ${count}:`n$_"
    }
    finally {
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}

if ($count -ge 3) {
    throw "Failed to provision AD after 3 retries."
}
