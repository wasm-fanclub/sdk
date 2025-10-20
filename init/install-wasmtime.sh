#!/bin/bash
source /opt/init/tags.env
export PROFILE="/etc/profile.d/wasmtime.sh"
export HOME=${HOME:-/root}

source $PROFILE

curl -fsSL https://wasmtime.dev/install.sh | bash -s -- --version "$WASMTIME_RELEASE"