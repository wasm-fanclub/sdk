#!/bin/bash
PROFILE_SCRIPT=/etc/profile.d/init/all.sh
: > $PROFILE_SCRIPT

cat << 'EOF' >> $PROFILE_SCRIPT
source /opt/init/tags.env
source /etc/profile.d/init/emsdk.sh
source /etc/profile.d/init/wasi-sdk.sh
source /etc/profile.d/init/system.sh
source /etc/profile.d/init/wasmtime.sh
source /etc/profile.d/init/wabt.sh
EOF