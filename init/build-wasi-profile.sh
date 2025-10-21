#!/bin/bash
source /opt/init/tags.env

PROFILE_NAME=wasi-sdk
UPSTREAM_REPO=WebAssembly/wasi-sdk

URL_PATH="$UPSTREAM_REPO/$WASI_SDK_RELEASE/docker/Dockerfile"

BASE_URL="https://raw.githubusercontent.com"
DOCKERFILE_URL="$BASE_URL/$URL_PATH"

PROFILE_SCRIPT=$(bash /opt/init/env-profile.sh "$PROFILE_NAME" "$DOCKERFILE_URL")

echo 'export WASI_SYSROOT="/opt/wasi-sdk/share/wasi-sysroot"' >> $PROFILE_SCRIPT
echo 'if [[ ":$PATH:" != *":/opt/wasi-sdk/bin:"* ]]; then export PATH="/opt/wasi-sdk/bin:$PATH"; fi' >> $PROFILE_SCRIPT