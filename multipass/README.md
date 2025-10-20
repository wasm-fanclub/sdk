# The Wasm Fanclub SDK Multipass Configuration

A cloud-init configuration file for setting up the Wasm Fanclub SDK environment on cloud-init compatible platforms, specifically tested with Multipass.

**Note about release builds:**
The version provided by the main branch uses curl to download the initialization scripts from the `init/` directory of this repository. To optimize releases, the tags that have a release on GitHub have these files automatically inserted into the cloud-init.yml write-files section. As you can see:
- [main](https://raw.githubusercontent.com/wasm-fanclub/sdk/main/multipass/cloud-init.yml) - init scripts are downloaded
- [v0.2.0](https://raw.githubusercontent.com/wasm-fanclub/sdk/v0.2.0/multipass/cloud-init.yml) - init scripts are already included

When using the main branch version, you can update /etc/cloud/metadata.tag to specify a different branch, tag, or commit hash to pull the init scripts from. You can also do the same for metadata.repo to pull from a different repository.

## Running with Multipass:

After cloning the repository, you can launch a Multipass instance with the Wasm Fanclub SDK environment using the following commands:

On bash:
```bash
cd "$(git rev-parse --show-toplevel)"
multipass launch \
    22.04 \
    --name wasm-fanclub-sdk \
    --cloud-init ./multipass/cloud-init.yml \
    --memory 4G \
    --disk 15G \
    --cpus 2 \
    --mount path/to/source_code:/src # --network <optional-network-interface>
multipass exec wasm-fanclub-sdk -- cloud-init status --wait
# if multipass launch times out, the --mount option is skipped, so remount as necessary:
# multipass mount path/to/source_code wasm-fanclub-sdk:/src

multipass exec wasm-fanclub-sdk -- bash /src/build.sh # or whatever script you want to run
```

On PowerShell:
```powershell
cd "$(git rev-parse --show-toplevel)"
multipass launch `
    22.04 `
    --name wasm-fanclub-sdk `
    --cloud-init ./multipass/cloud-init.yml `
    --memory 4G `
    --disk 15G `
    --cpus 2 `
    --mount path/to/source_code:/src # --network <optional-network-interface>
multipass exec wasm-fanclub-sdk -- bash -c "cloud-init status --wait && bash /src/build.sh"
# if multipass launch times out, the --mount option is skipped, so remount as necessary:
# multipass mount path/to/source_code wasm-fanclub-sdk:/src

multipass exec wasm-fanclub-sdk -- bash /src/dump-test.sh # or whatever script you want to run
```

**NOTE:** It is recommended that you specify an option for `--network` as using the default NAT interface may lead to very slow cloud initialization times.

**NOTE:** The base image with the entire SDK installed is approximately 5-6 GB in size. In the examples above, we allocate 15 GB of disk space to allow for building projects within the VM.
- Projects that have large dependencies or build artifacts outside of mounted volumes may require more disk space. Adjust `--disk` accordingly.
- Projects that don't require disk space outside of mounted volumes may be able to use less disk space. Adjust `--disk` accordingly.