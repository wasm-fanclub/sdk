#!/bin/bash
source /opt/init/tags.env
set -eou pipefail
export PROFILE="/etc/profile.d/init/wasmtime.sh"
export HOME=${HOME:-/root}

source $PROFILE

curl -fsSL https://wasmtime.dev/install.sh | bash -s -- --version "$WASMTIME_RELEASE"