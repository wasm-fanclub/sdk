#!/bin/bash
source /opt/init/tags.env

PROFILE_NAME=emsdk
UPSTREAM_REPO=emscripten-core/emsdk

URL_PATH="$UPSTREAM_REPO/$EMSDK_RELEASE/docker/Dockerfile"

BASE_URL="https://raw.githubusercontent.com"
DOCKERFILE_URL="$BASE_URL/$URL_PATH"

PROFILE_SCRIPT=$(bash /opt/init/env-profile.sh "$PROFILE_NAME" "$DOCKERFILE_URL")