param (
    [string] $customLocationResourceId,
    [string] $kubernetesVersion,
    [string] $osSku
)

$ErrorActionPreference = "Stop"

az config set extension.use_dynamic_install=yes_without_prompt

while ($true) {
    if ($env:ACTIONS_ID_TOKEN_REQUEST_TOKEN) {
        $resp = Invoke-WebRequest -Uri "$env:ACTIONS_ID_TOKEN_REQUEST_URL&audience=api://AzureADTokenExchange" -Headers @{"Authorization" = "bearer $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN"}
        $token = (echo $resp.Content | ConvertFrom-Json).value
    
        az login --federated-token $token --tenant $env:ARM_TENANT_ID -u $env:ARM_CLIENT_ID --service-principal
        az account set --subscription $env:ARM_SUBSCRIPTION_ID
    }

    $state = az aksarc get-versions --custom-location $customLocationResourceId -o json
    $pos = $state.IndexOf("{")
    $state = $state.Substring($pos)
    try {
        echo $state | ConvertFrom-Json | ConvertTo-Json -Compress -Depth 100
    } catch {
        echo $state
        throw $_
    }
    $ready = $false

    foreach ($version in (echo $state  | ConvertFrom-Json).properties.values) {
        if (!$kubernetesVersion.StartsWith($version.version)) {
            continue
        }

        if ($version.patchVersions.PSobject.Properties.name -notcontains $kubernetesVersion) {
            break
        }

        foreach ($readiness in $version.patchVersions.$kubernetesVersion.readiness) {
            if ($readiness.osSku -eq $osSku) {
                $ready = $readiness.ready
            }
        }
    }

    if ($ready) {
        echo "Kubernetes version $kubernetesVersion is ready for osSku $osSku."
        break
    }

    echo "Kubernetes version $kubernetesVersion is not ready yet for osSku $osSku. Retrying in 10 seconds."
    sleep 10
}
