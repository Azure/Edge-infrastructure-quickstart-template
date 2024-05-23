arch=$(uname -m)

if [[ $OSTYPE == *"linux"* ]]; then
    if [[ $arch == *"arm"* ]]; then
        wget "https://aka.ms/az-edge-module-export-linux-arm64?$1" -O az-edge-module-export
        wget "https://aka.ms/az-edge-site-scale-linux-arm64?$1" -O az-edge-site-scale
    else
        wget "https://aka.ms/az-edge-module-export-linux-amd64?$1" -O az-edge-module-export
        wget "https://aka.ms/az-edge-site-scale-linux-amd64?$1" -O az-edge-site-scale
    fi
elif [[ $OSTYPE == *"darwin"* ]]; then
    if [[ $arch == *"arm"* ]]; then
        wget "https://aka.ms/az-edge-module-export-darwin-arm64?$1" -O az-edge-module-export
        wget "https://aka.ms/az-edge-site-scale-darwin-arm64?$1" -O az-edge-site-scale
    else
        echo "Unsupported architecture for macOS"
    fi
else
    echo "Unsupported OS"
    exit 1
fi
