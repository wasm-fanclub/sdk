# The Wasm Fanclub SDK Docker Image

A pre-built Docker image can be found on GitHub Container Registry at `ghcr.io/wasm-fanclub/sdk:latest`.

## Running the Docker Image:
On bash:
```bash
docker run \
  --rm \
  -it \
  -v path/to/source_code:/src:rw \
  ghcr.io/wasm-fanclub/sdk:latest \
  bash /src/build.sh
```

On PowerShell:
```powershell
docker run `
  --rm `
  -it `
  -v path/to/source_code:/src:rw `
  ghcr.io/wasm-fanclub/sdk:latest `
  bash /src/build.sh
```

## Building the Docker Image:

After cloning the repository, you can build the Docker image using the following commands:

On bash:
```bash
cd "$(git rev-parse --show-toplevel)"
docker build -t ghcr.io/wasm-fanclub/sdk:latest -f docker/Dockerfile .
```

On PowerShell:
```powershell
cd "$(git rev-parse --show-toplevel)"
docker build -t ghcr.io/wasm-fanclub/sdk:latest -f docker/Dockerfile .
```

## Github Actions Usage
See the [root README.md](../README.md#github-actions-usage)
