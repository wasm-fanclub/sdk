#!/bin/bash
source /opt/init/tags.env

WASMTIME_HOME="/opt/wasmtime"

PROFILE_SCRIPT=/etc/profile.d/wasmtime.sh
: > $PROFILE_SCRIPT

echo "export WASMTIME_HOME=$WASMTIME_HOME" >> $PROFILE_SCRIPT
echo 'export PATH="$WASMTIME_HOME/bin:$PATH"' >> $PROFILE_SCRIPT