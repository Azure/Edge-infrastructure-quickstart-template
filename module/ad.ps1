param(
    $userName,
    $password,
    $siteID,
    $adouPath,
    $computerNames,
    $ip,
    $domainFqdn,
    $ifdeleteadou,
    $domainAdminUser,
    $domainAdminPassword
)

$script:ErrorActionPreference = 'Stop'
echo "Enter !"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secpasswd
enable-wsmancredssp -role client -delegatecomputer $ip -force
$session = New-PSSession -ComputerName $ip -Authentication Credssp -Credential $cred
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
    Install-Module AsHciADArtifactsPreCreationTool -Repository PSGallery -Force
    echo "Installed"
    Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
    echo "Add-KdsRootKey"

    
    New-HciAdObjectsPreCreation -Deploy -AzureStackLCMUserCredential $Using:domaincred -AsHciOUName $Using:adouPath -AsHciPhysicalNodeList $Using:computerNameList -DomainFQDN $Using:domainFqdn -AsHciClusterName "$Using:siteID-cl" -AsHciDeploymentPrefix $Using:siteID
}
