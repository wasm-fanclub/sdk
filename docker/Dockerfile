ARG UPSTREAM_TAG=v0.2.0-alpha
ARG UPSTREAM_REPO=wasm-fanclub/sdk

ARG WASI_SDK_RELEASE=latest
ARG EMSDK_RELEASE=latest
ARG WABT_RELEASE=main
ARG WASMTIME_RELEASE=latest

FROM ghcr.io/webassembly/wasi-sdk:${WASI_SDK_RELEASE} AS wasi
FROM emscripten/emsdk:${EMSDK_RELEASE}
COPY --from=wasi /opt/wasi-sdk /opt/wasi-sdk

RUN apt-get update && apt-get install -y clang lld llvm-dev

ARG UPSTREAM_TAG
ENV UPSTREAM_TAG=${UPSTREAM_TAG}
ARG UPSTREAM_REPO
ENV UPSTREAM_REPO=${UPSTREAM_REPO}

ARG WASI_SDK_RELEASE
ENV WASI_SDK_RELEASE=${WASI_SDK_RELEASE}
ARG EMSDK_RELEASE
ENV EMSDK_RELEASE=${EMSDK_RELEASE}
ARG WABT_RELEASE
ENV WABT_RELEASE=${WABT_RELEASE}
ARG WASMTIME_RELEASE
ENV WASMTIME_RELEASE=${WASMTIME_RELEASE}

COPY ./init/env-profile.sh /opt/init/env-profile.sh
RUN sed -i 's/\r$//' /opt/init/env-profile.sh

RUN <<EOF cat > /opt/init/tags.env
WASI_SDK_RELEASE=${WASI_SDK_RELEASE}
EMSDK_RELEASE=${EMSDK_RELEASE}
WABT_RELEASE=${WABT_RELEASE}
WASMTIME_RELEASE=${WASMTIME_RELEASE}
EOF
RUN sed -i 's/\r$//' /opt/init/tags.env

# WASI-SDK already installed, but we need to set ENV vars

COPY ./init/build-wasi-profile.sh /opt/init/build-wasi-profile.sh
RUN sed -i 's/\r$//' /opt/init/build-wasi-profile.sh
RUN bash /opt/init/build-wasi-profile.sh

# Emscripten already installed, and ENV vars are inherited
# - no additional steps needed

# Wasmtime and WABT installation

COPY ./init/build-wasmtime-profile.sh /opt/init/build-wasmtime-profile.sh
RUN sed -i 's/\r$//' /opt/init/build-wasmtime-profile.sh
RUN bash /opt/init/build-wasmtime-profile.sh

RUN echo "export PATH=\$WASMTIME_HOME/bin:\$PATH" >> /etc/profile.d/wasmtime.sh

COPY ./init/build-wabt-profile.sh /opt/init/build-wabt-profile.sh
RUN sed -i 's/\r$//' /opt/init/build-wabt-profile.sh
RUN bash /opt/init/build-wabt-profile.sh

COPY ./init/install-wasmtime.sh /opt/init/install-wasmtime.sh
RUN sed -i 's/\r$//' /opt/init/install-wasmtime.sh
RUN bash /opt/init/install-wasmtime.sh

COPY ./init/install-wabt.sh /opt/init/install-wabt.sh
RUN sed -i 's/\r$//' /opt/init/install-wabt.sh
RUN bash /opt/init/install-wabt.sh

COPY ./init/build-sdk-check.sh /opt/init/build-sdk-check.sh
RUN sed -i 's/\r$//' /opt/init/build-sdk-check.sh
RUN bash /opt/init/build-sdk-check.sh && bash /etc/profile.d/zzz-sdk-check.sh

WORKDIR /

ENTRYPOINT ["/bin/bash", "--login"]