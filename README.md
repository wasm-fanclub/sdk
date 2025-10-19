# Wasm Fanclub SDK

<img width="757" height="739" alt="image" src="https://github.com/user-attachments/assets/64f0a5a7-a593-4eee-af03-e7dc354bd464" />

## Overview

This repository provides an easy-to-use SDK aggregate for WebAssembly development, bundling together the Emscripten SDK, WASI-SDK, Wasmtime, and WABT tools. Currently, it targets Ubuntu on any platform that can be orchestrated with Dockerfiles or cloud-init (e.g., Multipass).

This can include:
- Ubuntu via:
  - [cloud-init.yml](multipass/cloud-init.yml)
    - On multipass (see [multipass/README.md](multipass/README.md) for usage)
    - On bare metal (via `cloud-init --file=multipass/cloud-init.yml`)
    - On emulated/container environments (see [cloud-init documentation](https://cloudinit.readthedocs.io/en/latest/howto/launching.html))
    - On cloud providers that support cloud-init (e.g., AWS, Azure, GCP, etc.)
  - [Dockerfile](docker/Dockerfile)
    - On Docker (see [docker/README.md](docker/README.md) for usage)
    - On GitHub Actions (see below for usage)
    - On other container orchestration platforms that support Docker images (e.g., Kubernetes, etc.)

## Included SDKs
- WASI-SDK - `/opt/wasi-sdk`
- Emscripten SDK - `/emsdk` (for consistency with official Emscripten Docker images)
- Wasmtime - `/opt/wasmtime`
- WABT - `/opt/wabt`

NOTE: PATH will typically look like this:
```bash
/opt/wasmtime/bin:/opt/wasi-sdk/bin:/opt/wabt/bin:/emsdk:/emsdk/upstream/emscripten:/emsdk/node/*/bin:$PATH
```
Note that precedence is generally wasmtime > wasi-sdk > wabt > emsdk > system. This is important, because wasi-sdk includes its own clang/clang++ toolchain. If you need the system clang/clang++, you should call them directly via `/usr/bin/clang` and `/usr/bin/clang++` or use `env -i bash --noprofile --norc` to start a clean shell without the PATH modifications.

## Tested Targets
- Orchestration-ware
  - Dockerfile
    - Docker (tested)
    - GH Actions (tested, see below for usage)
  - cloud-init.yml
    - Multipass (tested)
- Guest OS
  - Ubuntu 22.04 LTS (Jammy Jellyfish)
- SDK
  - Emscripten - 4.0.16
  - WASI - 27
  - Wasmtime - 37.0.2
  - WABT - 1.0.37

## GitHub Actions Usage
Since the spec for [action.yml does not support volume mounts](https://docs.github.com/en/actions/reference/workflows-and-actions/metadata-syntax#runs-for-docker-container-actions), we do not provide one.
- The concern and consideration for this was the fact that without volume mounts, you would have to clone the repository again inside the container in order to work with it, which is inefficient. Efficiency is important when considering GitHub Actions' usage limits.

Instead, we recommend you use the [jobs in a container API](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/run-jobs-in-a-container). Here is an example workflow snippet:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/wasm-fanclub/sdk:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Build with Emscripten
        run: |
          emcc your_code.c -o your_code.html

      - name: Build with WASI-SDK
        run: |
          clang your_code.c -o your_code.wasm --target=wasm32-wasi
          wasm32-wasi-clang your_code.c -o your_code.wasm

      - name: Use WABT tools
        run: |
          wat2wasm your_code.wat -o your_code.wasm
```
