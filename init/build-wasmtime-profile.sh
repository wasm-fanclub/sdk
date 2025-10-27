#!/bin/bash
source /opt/init/tags.env

WASMTIME_HOME="/opt/wasmtime"

PROFILE_SCRIPT=/etc/profile.d/init/wasmtime.sh
: > $PROFILE_SCRIPT

echo "export WASMTIME_HOME=$WASMTIME_HOME" >> $PROFILE_SCRIPT
echo 'if [[ ":$PATH:" != *":$WASMTIME_HOME/bin:"* ]]; then export PATH="$WASMTIME_HOME/bin:$PATH"; fi' >> $PROFILE_SCRIPT