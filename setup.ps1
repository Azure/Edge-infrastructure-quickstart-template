param (
    [string] $subscriptionId,
    [string] $resourceGroupName,
    [string] $storageAccountName,
    [string] $storageContainerName,

    [Parameter(ParameterSetName = 'Name')]
    [string] $servicePrincipalName,

    [Parameter(ParameterSetName = 'Id')]
    [string] $servicePrincipalId,

    [Parameter(ParameterSetName = 'Id')]
    [string] $servicePrincipalSecret = ""
)

$Script:ErrorActionPreference = "Stop"

# Check az and gh cli are installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is not installed. Please install it from https://aka.ms/installazurecliwindows"
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is not installed. Please install it from https://cli.github.com"
}

$gitHubRepoNameWithOwner = gh repo view --json nameWithOwner --jq ".nameWithOwner"

# Create "terraform" environment in the GitHub repo if not exists
$envExists = $false
echo "Checking if 'terraform' environment exists in the GitHub repo..."
gh api --method GET -H "Accept: application/vnd.github+json" "repos/$gitHubRepoNameWithOwner/environments/terraform"

if ($LASTEXITCODE -eq 0) {
    echo "Environment 'terraform' exists in the GitHub repo."
    $envExists = $true
}
else {
    echo "Environment 'terraform' does not exist in the GitHub repo."
}

if (-not $envExists) {
    echo "Creating 'terraform' environment in the GitHub repo..."
    gh api --method PUT -H "Accept: application/vnd.github+json" "repos/$gitHubRepoNameWithOwner/environments/terraform"
}

# Create service principal if not exists
$sp = $null

if ($servicePrincipalId) {
    $sp = az ad sp show --id $servicePrincipalId
}
else {
    if ($servicePrincipalName) {
        $sp = az ad sp create-for-rbac --name $servicePrincipalName
    }
}

if (-not $sp) {
    throw "Service principal not found or created."
}
$spid = echo $sp | ConvertFrom-Json | Select-Object -ExpandProperty appId

# Add federated credential for the service principal
echo "Adding federated credential for the service principal..."
$repoNameConverted = "${gitHubRepoNameWithOwner}" -replace "/", "_"
$jsonContent = @"
{
    "name": "${repoNameConverted}_environment_terraform",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${gitHubRepoNameWithOwner}:environment:terraform",
    "description": "service principal for terraform environment for repo $gitHubRepoNameWithOwner",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
"@
Set-Content $jsonContent -Path "$env:TEMP/terraformenv.json"
az ad app federated-credential create --id $spid --parameters "$env:TEMP/terraformenv.json"
$jsonContent = @"
{
    "name": "repo_${repoNameConverted}_pull_request",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${gitHubRepoNameWithOwner}:pull_request",
    "description": "service principal for pull request for repo $gitHubRepoNameWithOwner",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
"@
Set-Content $jsonContent -Path "$env:TEMP/pullrequest.json"
az ad app federated-credential create --id $spid --parameters "$env:TEMP/pullrequest.json"

# Assign roles for the service principal
echo "Granting permission Contributor/Key vault secrets officer/user access administrator to the service principal $spid..."
az role assignment create --role "Contributor" --assignee $spid --scope "/subscriptions/$subscriptionId"
az role assignment create --role "Key vault secrets officer" --assignee $spid --scope "/subscriptions/$subscriptionId"
az role assignment create --role "User Access Administrator" --assignee $spid --scope "/subscriptions/$subscriptionId"

if (-not $servicePrincipalSecret) {
    echo "Creating secret for the service principal..."
    $servicePrincipalSecret = (az ad app credential reset --id $spid | ConvertFrom-Json | Select-Object -ExpandProperty "password").Trim('"')
}

$hciRpOid=(az ad sp list --filter "appid eq '1412d89f-b8a8-4111-b4fd-e82905cbd85d'" --query "[0].id").Trim('"')


# Set github repo secrets
echo "Setting GitHub repo secrets..."
gh secret set AZURE_CLIENT_ID -b $spid
gh secret set AZURE_SUBSCRIPTION_ID -b $subscriptionId
gh secret set AZURE_TENANT_ID -b (az account show --query tenantId -o tsv)
gh secret set servicePrincipalId -b $spid
gh secret set servicePrincipalSecret -b $servicePrincipalSecret
gh secret set rpServicePrincipalObjectId -b $hciRpOid

$domainAdminUser = Read-Host "Enter the admin user name of domain controller. (Leave it empty if you prepare AD yourself)"
gh secret set domainAdminUser -b $domainAdminUser
$domainAdminPassword = Read-Host "Enter the admin password of domain controller. (Leave it empty if you prepare AD yourself)"
gh secret set domainAdminPassword -b $domainAdminPassword
$localAdminUser = Read-Host "Enter the local admin user name of HCI hosts."
gh secret set localAdminUser -b $localAdminUser
$localAdminPassword = Read-Host "Enter the local admin password of HCI hosts."
gh secret set localAdminPassword -b $localAdminPassword
$deploymentUserPassword = Read-Host "Enter the password for the deployment user."
gh secret set deploymentUserPassword -b $deploymentUserPassword

# Set local hook
echo "Setting local hook..."
git config --local core.hooksPath ./.azure/hooks/
echo "Local hook set successfully. You can reset it by running 'git config --local --unset core.hooksPath'."

# Set Terraform backend
echo "Setting Terraform backend..."
# check if the storage account exists
$storageAccount = az storage account show --name $storageAccountName --resource-group $resourceGroupName
if (-not $storageAccount) {
    echo "Creating storage account $storageAccountName in resource group $resourceGroupName for terraform backend..."
    az storage account create --name $storageAccountName --resource-group $resourceGroupName --sku Standard_LRS
}
$storageContainer = az storage container show --name $storageContainerName --account-name $storageAccountName --auth-mode login
if (-not $storageContainer) {
    echo "Creating storage container $storageContainerName in storage account $storageAccountName for terraform backend..."
    az storage container create --name $storageContainerName --account-name $storageAccountName --auth-mode login
}
# check if the container is empty
$blobCount = (az storage blob list --container-name $storageContainerName --account-name $storageAccountName | ConvertFrom-Json).Count
if ($blobCount -gt 0) {
    Write-Error "The storage container $storageContainerName in storage account $storageAccountName is not empty. Please empty it before setting it as Terraform backend."
    exit 1
}

# Replace placeholders in ./.azure/backend.tf
$backendTfPath = "./.azure/backend.tf"
$backendTfContent = Get-Content $backendTfPath
$backendTfContent = $backendTfContent -replace "<ResourceGroupName>", $resourceGroupName
$backendTfContent = $backendTfContent -replace "<StorageAccountName>", $storageAccountName
$backendTfContent = $backendTfContent -replace "<StorageContainerName>", $storageContainerName
Set-Content -Path $backendTfPath -Value $backendTfContent

echo "Local development environment is set up successfully."
Read-Host "You can continue to setup self-hosted runner. Press Enter to generate a token. Ctrl+C to exit"

$token = gh api --method POST -H "Accept: application/vnd.github+json" "/repos/$gitHubRepoNameWithOwner/actions/runners/registration-token" | ConvertFrom-Json | Select-Object -ExpandProperty token
echo "Token generated, please copy it and run the following command to register the runner: self-hosted-runner.ps1 $gitHubRepoNameWithOwner $token"
