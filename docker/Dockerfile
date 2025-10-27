ARG WASI_SDK_RELEASE=latest
ARG EMSDK_RELEASE=latest
ARG WABT_RELEASE=main
ARG WASMTIME_RELEASE=latest

FROM ghcr.io/webassembly/wasi-sdk:${WASI_SDK_RELEASE} AS wasi_sdk
FROM emscripten/emsdk:${EMSDK_RELEASE} AS emsdk

FROM ubuntu:24.04
COPY --from=wasi_sdk /opt/wasi-sdk /opt/wasi-sdk
COPY --from=emsdk /emsdk /opt/emsdk

RUN apt-get update && apt-get install -y clang lld llvm-dev

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

# Emscripten already installed, but we need to set ENV vars
COPY ./init/build-emsdk-profile.sh /opt/init/build-emsdk-profile.sh
RUN sed -i 's/\r$//' /opt/init/build-emsdk-profile.sh
RUN bash /opt/init/build-emsdk-profile.sh

# Wasmtime and WABT installation

COPY ./init/build-wasmtime-profile.sh /opt/init/build-wasmtime-profile.sh
RUN sed -i 's/\r$//' /opt/init/build-wasmtime-profile.sh
RUN bash /opt/init/build-wasmtime-profile.sh

COPY ./init/build-wabt-profile.sh /opt/init/build-wabt-profile.sh
RUN sed -i 's/\r$//' /opt/init/build-wabt-profile.sh
RUN bash /opt/init/build-wabt-profile.sh

COPY ./init/install-wasmtime.sh /opt/init/install-wasmtime.sh
RUN sed -i 's/\r$//' /opt/init/install-wasmtime.sh
RUN bash /opt/init/install-wasmtime.sh

COPY ./init/install-wabt.sh /opt/init/install-wabt.sh
RUN sed -i 's/\r$//' /opt/init/install-wabt.sh
RUN bash /opt/init/install-wabt.sh

RUN echo "## Update and install packages" \
    && apt-get -qq -y update \
    # Somewhere in here apt sets up tzdata which asks for your time zone and blocks
    # waiting for the answer which you can't give as docker build doesn't read from
    # the terminal. The env vars set here avoid the interactive prompt and set the TZ.
    && DEBIAN_FRONTEND="noninteractive" TZ="America/San_Francisco" apt-get -qq install -y --no-install-recommends \
        sudo \
        libxml2 \
        ca-certificates \
        python3 \
        python3-pip \
        wget \
        curl \
        zip \
        unzip \
        git \
        git-lfs \
        ssh-client \
        build-essential \
        make \
        ant \
        libidn12 \
        cmake \
        openjdk-11-jre-headless \
    # Standard Cleanup on Debian images
    && apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/debconf/*-old \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/?? \
    && rm -rf /usr/share/man/??_* \
    && echo "## Done"

WORKDIR /

ENTRYPOINT ["/bin/bash", "--login", "-c"]