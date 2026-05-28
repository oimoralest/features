# Neovim Feature

Installs Neovim from GitHub releases (prebuilt binaries).

## Options

| Option    | Type   | Default  | Description                                                                 |
|-----------|--------|----------|-----------------------------------------------------------------------------|
| `version` | string | `stable` | Version to install: `stable`, `nightly`, `latest`, or specific (e.g. `v0.10.0`) |

## Usage

```json
{
  "features": {
    "ghcr.io/oimoralest/features/neovim:1": {
      "version": "stable"
    }
  }
}
```

### Examples

**Install stable version (default):**
```json
"ghcr.io/oimoralest/features/neovim:1": {}
```

**Install nightly version:**
```json
"ghcr.io/oimoralest/features/neovim:1": {
  "version": "nightly"
}
```

**Install a specific version:**
```json
"ghcr.io/oimoralest/features/neovim:1": {
  "version": "v0.10.0"
}
```

## Supported architectures

- `x86_64` (linux64)
- `aarch64` / `arm64` (linux-arm64)

## Notes

This feature downloads the prebuilt binaries directly from [Neovim's GitHub Releases](https://github.com/neovim/neovim/releases), avoiding issues with apt repositories and GPG signatures.
