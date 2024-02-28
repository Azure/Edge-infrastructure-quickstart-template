param (
    [string] $customLocationResourceId,
    [string] $kubernetesVersion
)

$ErrorActionPreference = "Stop"

az config set extension.use_dynamic_install=yes_without_prompt

while ($true) {
    $state = az aksarc get-versions --custom-location $customLocationResourceId
    $pos = $state.IndexOf("{")
    $state = $state.Substring($pos)
    echo $state
    $ready = $true

    foreach ($version in (echo $state  | ConvertFrom-Json).properties.values) {
        if (!$kubernetesVersion.StartsWith($version.version)) {
            continue
        }

        if ($version.patchVersions.PSobject.Properties.name -notcontains $kubernetesVersion) {
            $ready = $false
            break
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

    echo "Kubernetes version $kubernetesVersion is not ready yet. Retrying in 10 seconds."
    sleep 10
}
