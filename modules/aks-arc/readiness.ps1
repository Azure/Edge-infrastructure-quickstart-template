param (
    [string] $customLocationResourceId,
    [string] $kubernetesVersion
)

$ErrorActionPreference = "Stop"

az config set extension.use_dynamic_install=yes_without_prompt

while ($true) {
    $state = az aksarc get-versions --custom-location $customLocationResourceId | ConvertFrom-Json
    echo $state
    $ready = $true

    foreach ($version in $state.properties.values) {
        if (!$kubernetesVersion.StartsWith($version.version)) {
            continue
        }

        if ($version.patchVersions.PSobject.Properties.name -notcontains $kubernetesVersion) {
            throw "Kubernetes version $kubernetesVersion is not available in the custom location $customLocationResourceId."
        }

        if (!$version.patchVersions.$kubernetesVersion.readiness) {
            throw "Kubernetes version $kubernetesVersion readiness is not available in the custom location $customLocationResourceId."
        }

        foreach ($readiness in $version.patchVersions.$kubernetesVersion.readiness) {
            if (!$readiness.ready) {
                $ready = $false
                echo "Kubernetes version $kubernetesVersion is not ready yet."
            }
        }
    }

    if ($ready) {
        echo "Kubernetes version $kubernetesVersion is ready."
        break
    }
    sleep 10
}
