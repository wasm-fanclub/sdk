#!/bin/bash
source /opt/init/tags.env
set -eou pipefail
export PROFILE="/etc/profile.d/init/emsdk.sh"

source $PROFILE

UPSTREAM_REPO="emscripten-core/emsdk"

git clone "https://github.com/$UPSTREAM_REPO" "$EMSDK" \
    --branch "$EMSDK_RELEASE" \
    --depth 1

cd "$EMSDK"
./emsdk install "$EMSDK_RELEASE"
./emsdk activate "$EMSDK_RELEASE"

chmod 777 ${EMSDK}/upstream/emscripten
chmod -R 777 ${EMSDK}/upstream/emscripten/cache
echo "int main() { return 0; }" > hello.c
${EMSDK}/upstream/emscripten/emcc hello.c
cat ${EMSDK}/upstream/emscripten/cache/sanity.txt

source ${EMSDK}/emsdk_env.sh
strip -s `which node`
rm -rf ${EMSDK}/upstream/emscripten/tests
find ${EMSDK}/upstream/emscripten -type f -exec strip -s {} + || true

sudo chmod -R a+w ${EMSDK}/upstream/emscripten/cache