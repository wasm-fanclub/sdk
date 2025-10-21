#!/bin/bash
source /opt/init/tags.env

WABT_HOME="/opt/wabt"

PROFILE_SCRIPT=/etc/profile.d/wabt.sh
: > $PROFILE_SCRIPT

echo "export WABT_HOME=$WABT_HOME" >> $PROFILE_SCRIPT
echo 'if [[ ":$PATH:" != *":$WABT_HOME/bin:"* ]]; then export PATH="$WABT_HOME/bin:$PATH"; fi' >> $PROFILE_SCRIPT