ARG WASI_SDK_RELEASE=wasi-sdk-27
ARG EMSDK_RELEASE=4.0.16
ARG WABT_RELEASE=1.0.37
ARG WASMTIME_RELEASE=v37.0.2

FROM ghcr.io/webassembly/wasi-sdk:${WASI_SDK_RELEASE} AS wasi
FROM emscripten/emsdk:${EMSDK_RELEASE}
COPY --from=wasi /opt/wasi-sdk /opt/wasi-sdk

ARG WASI_SDK_RELEASE
ARG EMSDK_RELEASE
ARG WABT_RELEASE
ARG WASMTIME_RELEASE

# WASI and Emscripten already installed. Last ENVs that are needed:
ENV WASI_SDK_RELEASE=${WASI_SDK_RELEASE}
ENV EMSDK_RELEASE=${EMSDK_RELEASE}

ENV WASI_SYSROOT=/opt/wasi-sdk/share/wasi-sysroot

# Wasmtime installation
ENV WASMTIME_RELEASE=${WASMTIME_RELEASE}
ENV WASMTIME_HOME=/opt/wasmtime

RUN curl -fsSL https://wasmtime.dev/install.sh | bash -s -- --version "$WASMTIME_RELEASE"

# WABT installation
ENV WABT_RELEASE=${WABT_RELEASE}
ENV WABT_HOME=/opt/wabt

RUN apt-get update && apt-get install -y clang lld llvm-dev

ENV WABT_BUILD_ARGS="-DBUILD_TESTS=OFF \
    -DWITH_WASI=ON \
    -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF"

RUN git clone --depth 1 -b "$WABT_RELEASE" https://github.com/WebAssembly/wabt "$WABT_HOME" && \
    cd "$WABT_HOME" && \ 
    git submodule update --init --recursive && \
    cmake $WABT_BUILD_ARGS -DCMAKE_INSTALL_PREFIX=$WABT_HOME/bin && \
    cmake -S . -B build $WABT_BUILD_ARGS -DCMAKE_INSTALL_PREFIX=$WABT_HOME/bin && \
    cmake --build build && \
    cmake --install build

# Mirror cloud-init.yml PATH setup
ENV PATH="${WASMTIME_HOME}/bin:/opt/wasi-sdk/bin:${WABT_HOME}/bin:${PATH}"

# Verify installations
RUN <<EOT cat > /etc/profile.d/zzz-sdk-check.sh
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
EOT

RUN chmod +x /etc/profile.d/zzz-sdk-check.sh
RUN bash /etc/profile.d/zzz-sdk-check.sh

ENTRYPOINT ["/bin/bash", "--"]