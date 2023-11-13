param(
    $userName,
    $password,
    $siteName,
    $adouPath,
    $computerNameList,
    $ip,
    $domainSuffix,
    $ifdeleteadou
)

$script:ErrorActionPreference = 'Stop'
echo "Enter !"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secpasswd
enable-wsmancredssp -role client -delegatecomputer $ip -force
$session = New-PSSession -ComputerName $ip -Authentication Credssp -Credential $cred

if ($ifdeleteadou) {
    Invoke-Command -Session $session -ScriptBlock {
        $OUPrefixList = @("OU=Computers,", "OU=Users,", "")
        foreach ($prefix in $OUPrefixList) {
            $ouname = "$prefix$adouPath"
            $ou = Get-ADOrganizationalUnit -Identity $ouname
            if ($ou) {
                Set-ADOrganizationalUnit -Identity $ouname -ProtectedFromAccidentalDeletion $false
                $ou | Remove-ADOrganizationalUnit -Recursive -Confirm:$False 
                echo "Deleted adou: $ouname"
            }
        }
    }
    
}

Invoke-Command -Session $session -ScriptBlock {
    Install-Module AsHciADArtifactsPreCreationTool -Repository PSGallery
    Import-Module .\AsHciADArtifactsPreCreationTool.psm1
    Add-KdsRootKey -EffectiveTime ((Get-Date).addhours(-10))
    New-HciAdObjectsPreCreation -Deploy -AzureStackLCMUserCredential (Get-Credential) -AsHciOUName $adouPath -AsHciPhysicalNodeList @($computerNameList) -DomainFQDN $domainSuffix -AsHciClusterName $siteName -AsHciDeploymentPrefix "<Deployment prefix>"
}
