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

BUILD_ARGS=()
while IFS= read -r line; do
  line="${line#"${line%%[![:space:]]*}"}" # remove leading
  line="${line%"${line##*[![:space:]]}"}" # remove trailing
  [[ -z "$line" ]] && continue            # skip empty lines
  BUILD_ARGS+=(--build-arg "$line")
done < init/tags.env

docker build -t ghcr.io/wasm-fanclub/sdk:latest -f docker/Dockerfile "${BUILD_ARGS[@]}" . # --progress=plain
```

On PowerShell:
```powershell
cd "$(git rev-parse --show-toplevel)"

$BUILD_ARGS = @()
cat init/tags.env | ForEach-Object {
  if (-not [string]::IsNullOrWhiteSpace($_)) {
    $BUILD_ARGS += "--build-arg"
    $BUILD_ARGS += "$_".trim()
  }
}

docker build -t ghcr.io/wasm-fanclub/sdk:latest -f docker/Dockerfile @BUILD_ARGS . # --progress=plain
```

## Github Actions Usage
See the [root README.md](../README.md#github-actions-usage)
