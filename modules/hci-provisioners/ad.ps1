param(
    $userName,
    $password,
    $authType,
    $siteID,
    $clusterName,
    $adouPath,
    $computerNames,
    $ip, $port,
    $domainFqdn,
    $ifdeleteadou,
    $deploymentUserName,
    $deploymentUserPassword
)

$script:ErrorActionPreference = 'Stop'
echo "Enter !"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$domainShort = $domainFqdn.Split(".")[0]
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList "$domainShort\$username", $secpasswd

if ($authType -eq "CredSSP") {
    try {
        Enable-WSManCredSSP -Role Client -DelegateComputer $ip -Force
    } catch {
        echo "Enable-WSManCredSSP failed"
    }
}

$session = New-PSSession -ComputerName $ip -Port $port -Authentication $authType -Credential $cred
$computerNameList = $computerNames -split ","
echo $computerNameList
if ($ifdeleteadou) {
    Invoke-Command -Session $session -ScriptBlock {
        $OUPrefixList = @("OU=Computers,", "OU=Users,", "")
        foreach ($prefix in $OUPrefixList) {
            $ouname = "$prefix$Using:adouPath"
            echo "try to get OU: $ouname"
            Try{
                $ou = Get-ADOrganizationalUnit -Identity $ouname
            } Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
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
$lcmCred = New-Object System.Management.Automation.PSCredential -ArgumentList $deploymentUserName, $deploymentSecPasswd
Invoke-Command -Session $session -ScriptBlock {
    echo "Install Nuget Provider"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    echo "Install AsHciADArtifactsPreCreationTool"
    Install-Module AsHciADArtifactsPreCreationTool -Repository PSGallery -Force -Confirm:$false
    echo "Add KdsRootKey"
    Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
    echo "New HciAdObjectsPreCreation"    
    New-HciAdObjectsPreCreation -Deploy -AzureStackLCMUserCredential $Using:lcmCred -AsHciOUName $Using:adouPath -AsHciPhysicalNodeList $Using:computerNameList -DomainFQDN $Using:domainFqdn -AsHciClusterName $Using:clusterName -AsHciDeploymentPrefix $Using:siteID
}
