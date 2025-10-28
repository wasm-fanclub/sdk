#!/bin/bash
source /opt/init/tags.env
set -eou pipefail

PROFILE_NAME=emsdk
UPSTREAM_REPO=emscripten-core/emsdk

URL_PATH="$UPSTREAM_REPO/$EMSDK_RELEASE/docker/Dockerfile"

BASE_URL="https://raw.githubusercontent.com"
DOCKERFILE_URL="$BASE_URL/$URL_PATH"

PROFILE_SCRIPT=$(bash /opt/init/env-profile.sh "$PROFILE_NAME" "$DOCKERFILE_URL")

EMSDK="/opt/emsdk"

# Cleanup and set EMSDK path
awk -v EMSDK="$EMSDK" '
/^export[[:space:]]+EMSDK=/ {
  if (!done) {
    print "export EMSDK=\"'"$EMSDK"'\"";
    done = 1;
  }
  next;
}
{
  line = $0;
  # Replace any /emsdk or /emsdk/... that begins at the root (start or after non-path char)
  while (match(line, /(^|[^[:alnum:]_\/])(\/emsdk)(\/[^[:space:]]*)?/)) {
    prefix = substr(line, 1, RSTART - 1);
    matched = substr(line, RSTART, RLENGTH);
    suffix = substr(line, RSTART + RLENGTH);
    sub(/\/emsdk/, EMSDK, matched);
    line = prefix matched suffix;
  }
  print line;
}
' "${PROFILE_SCRIPT}" | tee "${PROFILE_SCRIPT}.tmp" > /dev/null
mv "${PROFILE_SCRIPT}.tmp" "${PROFILE_SCRIPT}"

echo "export CC=\"$EMSDK/upstream/emscripten/emcc\"" >> $PROFILE_SCRIPT
echo "export CXX=\"$EMSDK/upstream/emscripten/em++\"" >> $PROFILE_SCRIPT
echo "export LD=\"$EMSDK/upstream/emscripten/emcc\"" >> $PROFILE_SCRIPT
echo "export AR=\"$EMSDK/upstream/emscripten/emar\"" >> $PROFILE_SCRIPT
echo "export RANLIB=\"$EMSDK/upstream/emscripten/emranlib\"" >> $PROFILE_SCRIPT
echo "export EMSCRIPTEN_SYSROOT=\"$EMSDK/upstream/emscripten/cache/sysroot\"" >> $PROFILE_SCRIPT