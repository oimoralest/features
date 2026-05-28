# Lazygit Feature

Installs [Lazygit](https://github.com/jesseduffield/lazygit) from GitHub releases (prebuilt binaries).

## Options

| Option    | Type   | Default  | Description                                                                       |
|-----------|--------|----------|-----------------------------------------------------------------------------------|
| `version` | string | `latest` | Lazygit version to install: `latest` or a specific version (e.g. `0.43.1` or `v0.43.1`) |

## Usage

```json
{
  "features": {
    "ghcr.io/oimoralest/features/lazygit:1": {
      "version": "latest"
    }
  }
}
```

### Examples

**Install latest version (default):**
```json
"ghcr.io/oimoralest/features/lazygit:1": {}
```

**Install a specific version:**
```json
"ghcr.io/oimoralest/features/lazygit:1": {
  "version": "0.43.1"
}
```

The leading `v` is optional — both `0.43.1` and `v0.43.1` work.

## Supported architectures

- `x86_64` (Intel/AMD 64-bit)
- `aarch64` / `arm64` (ARM 64-bit)
- `armv6l` / `armv7l` (ARM 32-bit, uses the `armv6` build)

## Notes

This feature downloads the prebuilt binaries directly from [Lazygit's GitHub Releases](https://github.com/jesseduffield/lazygit/releases). Most distro repos either don't ship lazygit or ship outdated versions, so the GitHub release is the recommended source.

Requires `curl` and `tar`, which are present in the standard devcontainer base images (and in [`common-utils`](https://github.com/devcontainers/features/tree/main/src/common-utils)).
