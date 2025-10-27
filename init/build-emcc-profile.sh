#!/bin/bash
source /opt/init/tags.env

PROFILE_NAME=emsdk
UPSTREAM_REPO=emscripten-core/emsdk

URL_PATH="$UPSTREAM_REPO/$EMSDK_RELEASE/docker/Dockerfile"

BASE_URL="https://raw.githubusercontent.com"
DOCKERFILE_URL="$BASE_URL/$URL_PATH"

PROFILE_SCRIPT=$(bash /opt/init/env-profile.sh "$PROFILE_NAME" "$DOCKERFILE_URL")

EMSDK="/opt/emsdk"

# Cleanup and set EMSDK path
awk '
/^export[[:space:]]+EMSDK=/ {
  if (!done) {
    print "export EMSDK=\"'"$EMSDK"'\"";
    done = 1;
  }
  next;
}
{ print }
' "${PROFILE_SCRIPT}" | tee "${PROFILE_SCRIPT}.tmp" > /dev/null
mv "${PROFILE_SCRIPT}.tmp" "${PROFILE_SCRIPT}"

echo "export CC=\"$EMSDK/upstream/emscripten/emcc\"" >> $PROFILE_SCRIPT
echo "export CXX=\"$EMSDK/upstream/emscripten/em++\"" >> $PROFILE_SCRIPT
echo "export LD=\"$EMSDK/upstream/emscripten/emcc\"" >> $PROFILE_SCRIPT
echo "export AR=\"$EMSDK/upstream/emscripten/emar\"" >> $PROFILE_SCRIPT
echo "export RANLIB=\"$EMSDK/upstream/emscripten/emranlib\"" >> $PROFILE_SCRIPT
echo "export EMSCRIPTEN_SYSROOT=\"$EMSDK/upstream/emscripten/cache/sysroot\"" >> $PROFILE_SCRIPT