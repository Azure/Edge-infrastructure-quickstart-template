arch=$(uname -m)

if [[ $OSTYPE == *"linux"* ]]; then
    if [[ $arch == *"arm"* ]]; then
        wget "https://aka.ms/az-edge-site-scale-linux-arm64" -O az-edge-site-scale
    else
        wget "https://aka.ms/az-edge-site-scale-linux-amd64" -O az-edge-site-scale
    fi
elif [[ $OSTYPE == *"darwin"* ]]; then
    if [[ $arch == *"arm"* ]]; then
        wget "https://aka.ms/az-edge-site-scale-darwin-arm64" -O az-edge-site-scale
    else
        echo "Unsupported architecture for macOS"
    fi
else
    echo "Unsupported OS"
    exit 1
fi
