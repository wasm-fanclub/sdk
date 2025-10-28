#!/bin/bash
source /opt/init/tags.env
set -eou pipefail
export PROFILE="/etc/profile.d/init/wabt.sh"

source $PROFILE

# temporarily override WASI SDK CC/CXX to use system clang for WABT build
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
export AR=/usr/bin/llvm-ar
export RANLIB=/usr/bin/llvm-ranlib
export LD=/usr/bin/ld.lld

UPSTREAM_REPO="WebAssembly/wabt"
git clone "https://github.com/$UPSTREAM_REPO" "$WABT_HOME" \
    --branch "$WABT_RELEASE" \
    --depth 1

cd "$WABT_HOME"
git submodule update --init --recursive

WABT_BUILD_ARGS="-DBUILD_TESTS=OFF \
    -DWITH_WASI=ON \
    -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF"

cmake $WABT_BUILD_ARGS -DCMAKE_INSTALL_PREFIX=$WABT_HOME/bin
cmake -S . -B build $WABT_BUILD_ARGS -DCMAKE_INSTALL_PREFIX=$WABT_HOME/bin
cmake --build build
cmake --install build