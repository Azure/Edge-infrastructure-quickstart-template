param(
    $userName,
    $password,
    $siteID,
    $clusterName,
    $adouPath,
    $computerNames,
    $ip, $port,
    $domainFqdn,
    $ifdeleteadou,
    $domainAdminUser,
    $domainAdminPassword
)

$script:ErrorActionPreference = 'Stop'
echo "Enter !"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secpasswd
try {
    Enable-WSManCredSSP -Role Client -DelegateComputer $ip -Force
} catch {
    echo "Enable-WSManCredSSP failed"
}
$session = New-PSSession -ComputerName $ip -Port $port -Authentication Credssp -Credential $cred
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
$domainsecpasswd = ConvertTo-SecureString $domainAdminPassword -AsPlainText -Force
$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $domainAdminUser, $domainsecpasswd
Invoke-Command -Session $session -ScriptBlock {
    echo "Install Nuget Provider"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    echo "Install AsHciADArtifactsPreCreationTool"
    Install-Module AsHciADArtifactsPreCreationTool -Repository PSGallery -Force -Confirm:$false
    echo "Add KdsRootKey"
    Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
    echo "New HciAdObjectsPreCreation"    
    New-HciAdObjectsPreCreation -Deploy -AzureStackLCMUserCredential $Using:domaincred -AsHciOUName $Using:adouPath -AsHciPhysicalNodeList $Using:computerNameList -DomainFQDN $Using:domainFqdn -AsHciClusterName $Using:clusterName -AsHciDeploymentPrefix $Using:siteID
}
