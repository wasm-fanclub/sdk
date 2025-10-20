#!/bin/bash
PROFILE_SCRIPT=/etc/profile.d/zzz-sdk-check.sh

cat << 'EOF' > $PROFILE_SCRIPT
#!/usr/bin/env bash
echo ""
echo ""
echo -e "\033[1;33mSystem clang:\033[0m $(env -i bash --norc --noprofile -c "which clang") --version"
env -i bash --norc --noprofile -c "clang --version"
echo ""
echo -e "\033[1;31mWASI SDK:\033[0m $(which clang) --version"
clang --version
echo ""
echo -e "\033[1;31mEmscripten SDK:\033[0m $(which emcc) --version"
emcc --version
echo ""
echo -e "\033[1;36mWasmtime:\033[0m $(which wasmtime) --version"
wasmtime --version
echo ""
echo -e "\033[1;36mWABT:\033[0m $(which wat2wasm) --version"
wat2wasm --version
echo ""
EOF