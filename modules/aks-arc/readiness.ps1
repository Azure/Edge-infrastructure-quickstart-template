param (
    [string] $customLocationResourceId,
    [string] $kubernetesVersion,
    [string] $osSku
)

$ErrorActionPreference = "Stop"

az config set extension.use_dynamic_install=yes_without_prompt

while ($true) {
    $state = az aksarc get-versions --custom-location $customLocationResourceId
    $pos = $state.IndexOf("{")
    $state = $state.Substring($pos)
    echo $state | ConvertFrom-Json | ConvertTo-Json -Compress -Depth 100
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
