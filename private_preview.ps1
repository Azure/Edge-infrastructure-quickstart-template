param (
    [string]$PRIVATE_PREVIEW_SAS
)

Invoke-WebRequest "https://aka.ms/az-edge-module-export-windows-amd64?$PRIVATE_PREVIEW_SAS" -OutFile az-edge-module-export.exe
Invoke-WebRequest "https://aka.ms/az-edge-site-scale-linux-amd64?$PRIVATE_PREVIEW_SAS" -OutFile az-edge-site-scale.exe
