#!/bin/bash
PROFILE_SCRIPT=/etc/profile.d/init/system.sh
: > $PROFILE_SCRIPT

cat << 'EOF' >> $PROFILE_SCRIPT
source /opt/init/tags.env

export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"
export LD="/usr/bin/ld.lld"
export AR="/usr/bin/llvm-ar"
export RANLIB="/usr/bin/llvm-ranlib"
EOF