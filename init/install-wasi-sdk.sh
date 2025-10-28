#!/bin/bash
source /opt/init/tags.env
set -eou pipefail
export PROFILE="/etc/profile.d/init/wasi-sdk.sh"

source $PROFILE

ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    ARCH="x86_64"
fi

UPSTREAM_REPO="WebAssembly/wasi-sdk"
API_PATH="repos/$UPSTREAM_REPO/releases/tags/$WASI_SDK_RELEASE"
API_BASE="https://api.github.com"

API_URL="$API_BASE/$API_PATH"
API_RESPONSE=$(curl -sL "$API_URL")

JQ_FILTER='.assets[] | select(.name | test("\($arch)-linux\\.deb$"))'
JQ_QUERY="$JQ_FILTER | .browser_download_url"

DOWNLOAD_URL=$(echo "$API_RESPONSE" | jq -r --arg arch "$ARCH" "$JQ_QUERY")

echo "Installing WASI SDK"
echo "- Release: $WASI_SDK_RELEASE"
echo "- Arch: $ARCH"
echo "- Download URL: $DOWNLOAD_URL"

wget "$DOWNLOAD_URL" -O /tmp/wasi-sdk.deb
dpkg -i /tmp/wasi-sdk.deb || apt-get -f install -y
rm /tmp/wasi-sdk.deb