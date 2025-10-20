#!/bin/bash
source /opt/init/tags.env

WABT_HOME="/opt/wabt"

PROFILE_SCRIPT=/etc/profile.d/wabt.sh
: > $PROFILE_SCRIPT

echo "export WABT_HOME=$WABT_HOME" >> $PROFILE_SCRIPT
echo 'export PATH="$WABT_HOME/bin:$PATH"' >> $PROFILE_SCRIPT