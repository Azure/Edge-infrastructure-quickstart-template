az login
$spName="<yourServicePrincipleName>" #Replace it!
$yoursubscription="<yourSubscription>" #Replace it!
$yourreponame="<orignizationName>/<repoName>" #Replace it!

az account set --subscription $yoursubscription

az ad sp create-for-rbac --name $spName

$spid = az ad sp list --display-name $spName --query "[0].appId" -o tsv
$reponamewithoutslash = $yourreponame -replace "/", "_"
$jsonContent = @"
{
    "name": "${reponamewithoutslash}_environment_terraform",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${yourreponame}:environment:terraform",
    "description": "service principal for terraform environment for repo $yourreponame",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
"@
Set-Content $jsonContent -Path "$env:TEMP/terraformenv.json"
az ad app federated-credential create --id $spid --parameters "$env:TEMP/terraformenv.json"
$jsonContent = @"
{
    "name": "repo_${reponamewithoutslash}_pull_request",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${yourreponame}:pull_request",
    "description": "service principal for pull request for repo $yourreponame",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
"@
Set-Content $jsonContent -Path "$env:TEMP/pullrequest.json"
az ad app federated-credential create --id $spid --parameters "$env:TEMP/pullrequest.json"

$pass = az ad app credential reset --id $spid

echo "grant permission Contributor/Key vault secrets officer/user access administrator to the service principal $spName"
az role assignment create --role "Contributor" --assignee $spid --scope "/subscriptions/$yoursubscription"
az role assignment create --role "Key vault secrets officer" --assignee $spid --scope "/subscriptions/$yoursubscription"
az role assignment create --role "User Access Administrator" --assignee $spid --scope "/subscriptions/$yoursubscription"

$rpid=az ad sp list --filter "appid eq '1412d89f-b8a8-4111-b4fd-e82905cbd85d'" --query "[0].id"

echo "set sp related secret with"
echo $pass
$password = $pass | ConvertFrom-Json | Select-Object -ExpandProperty "password"
echo "set repository secret rpServicePrincipalObjectId with $rpid"
echo "set repository secret servicePrincipalSecret with $password"
