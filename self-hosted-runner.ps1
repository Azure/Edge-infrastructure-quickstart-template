param (
)

$Script:ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    echo "Azure CLI is not installed. Installing..."
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    echo "Git is not installed. Installing..."
    # get latest download url for git-for-windows 64-bit exe
    $git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
    $asset = Invoke-RestMethod -Method Get -Uri $git_url | % assets | where name -like "*64-bit.exe"
    # download installer
    $installer = "$env:temp\$($asset.name)"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer
    # run installer
    Start-Process -FilePath $installer -Wait
}

$gitBashPath = "C:\Program Files\Git\usr\bin\"
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitBashPath = (Get-Command git).Source.Replace("cmd\git.exe", "usr\bin\")
}
$path = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
if ($path -notlike "*$gitBashPath*") {
    echo "Adding default git bash location to system PATH..."
    $path += ";$gitBashPath"
    [System.Environment]::SetEnvironmentVariable('Path', $path, [System.EnvironmentVariableTarget]::Machine)
}

echo "Enabling client CredSSP..."
Set-Item wsman:localhost\client\trustedhosts -value *

$key = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
if (!(Test-Path $key)) {
    md $key
}
New-ItemProperty -Path $key -Name AllowFreshCredentials -Value 1 -PropertyType Dword -Force            

$key = Join-Path $key 'AllowFreshCredentials'
if (!(Test-Path $key)) {
    md $key
}

if (!(Get-ItemProperty -Path $key -Name 'AzureArcIaCAutomation' -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $key -Name 'AzureArcIaCAutomation' -Value 'WSMAN/*' -PropertyType String -Force
}
