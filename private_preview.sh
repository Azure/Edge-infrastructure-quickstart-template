arch=$(uname -m)

if [[ $arch == *"amd"* ]]; then
    wget "https://aka.ms/az-edge-module-export-linux-arm64?$1" -O az-edge-module-export
    wget "https://aka.ms/az-edge-site-scale-linux-arm64?$1" -O az-edge-site-scale
else
    wget "https://aka.ms/az-edge-module-export-linux-amd64?$1" -O az-edge-module-export
    wget "https://aka.ms/az-edge-site-scale-linux-amd64?$1" -O az-edge-site-scale
fi

