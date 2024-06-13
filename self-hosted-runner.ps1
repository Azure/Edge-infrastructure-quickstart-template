param (
    [string] $gitHubRepoNameWithOwner,
    [string] $runnerToken
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

$env:path = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

$gitBashPath = (Get-Command git).Source.Replace("cmd\git.exe", "usr\bin\")
if ($env:path -notlike "*$gitBashPath*") {
    echo "Adding default git bash location to system PATH..."
    $env:path += ";$gitBashPath"
    [System.Environment]::SetEnvironmentVariable('Path', $env:path, [System.EnvironmentVariableTarget]::Machine)
}

echo "Enabling client CredSSP..."
Set-Item wsman:localhost\client\trustedhosts -value *
Enable-WSManCredSSP -Role Client -DelegateComputer *

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

echo "Registering self-hosted runner..."
mkdir ar
cd ar
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-win-x64-2.317.0.zip -OutFile actions-runner-win-x64-2.317.0.zip
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.317.0.zip", "$PWD")
./config.cmd --url https://github.com/$gitHubRepoNameWithOwner --token $runnerToken --runasservice
