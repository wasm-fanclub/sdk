#!/bin/bash
PROFILE_SCRIPT=/etc/profile.d/zzz-sdk.sh
: > $PROFILE_SCRIPT

cat << 'EOF' >> $PROFILE_SCRIPT
source /opt/init/tags.env

echo -e "\033[1;36mAvailable WASM Fanclub SDK Build Profiles:\033[0m"
# iterate /etc/profile.d/init/ and print the source commands to console, so user knows how to load them
for profile in /etc/profile.d/init/*.sh; do
    profile_name=$(basename "$profile")
    base_name="${profile_name%.*}"
    echo -e "  \033[1;90msource \033[0m\033[38;5;186m/etc/profile.d/init/$profile_name\033[0m"
done
EOF