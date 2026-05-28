# Custom Dev Container Features

A collection of custom features for [Dev Containers](https://containers.dev), published as OCI artifacts in GitHub Container Registry.

## Available features

### Tmux (`ghcr.io/oimoralest/features/tmux`)

Installs tmux (terminal multiplexer) with automatic Linux distribution detection.

- Automatic package manager detection (apt, apk, yum, dnf, pacman, zypper)
- Optional TPM (Tmux Plugin Manager) installation
- Example config file included

```json
{
  "features": {
    "ghcr.io/oimoralest/features/tmux:1": {
      "installPluginManager": true
    }
  }
}
```

📖 [Full documentation](./src/tmux/README.md)

---

### Neovim (`ghcr.io/oimoralest/features/neovim`)

Installs Neovim from GitHub releases (prebuilt binaries).

- Supports `stable`, `nightly`, `latest`, or a specific version (e.g. `v0.10.0`)
- Official binaries — does not compile from source

```json
{
  "features": {
    "ghcr.io/oimoralest/features/neovim:1": {
      "version": "stable"
    }
  }
}
```

📖 [Full documentation](./src/neovim/README.md)

---

### Ripgrep (`ghcr.io/oimoralest/features/ripgrep`)

Installs ripgrep (rg), an extremely fast search tool.

- Automatic detection of distribution, package manager, and architecture
- Install from repos or from GitHub releases (for a specific version)
- Automatic fallback between install methods

```json
{
  "features": {
    "ghcr.io/oimoralest/features/ripgrep:1": {
      "version": "14.1.0",
      "installFromGithub": true
    }
  }
}
```

📖 [Full documentation](./src/ripgrep/README.md)

---

## How to use

### 1. Add the features to your `devcontainer.json`

```json
{
  "name": "My Project",
  "features": {
    "ghcr.io/oimoralest/features/tmux:1": {},
    "ghcr.io/oimoralest/features/neovim:1": {},
    "ghcr.io/oimoralest/features/ripgrep:1": {}
  }
}
```

The `:1` tag always points to the latest `1.x.y` release. Use `:latest` for the most recent version, or a specific tag (`:1.0.0`) to pin the version.

### 2. Rebuild the container

**VS Code:** `Cmd/Ctrl + Shift + P` → "Dev Containers: Rebuild Container"

**Terminal:**
```bash
devcontainer up --workspace-folder .
```

### 3. Verify the installation

```bash
tmux -V
nvim --version
rg --version
```

## Supported distributions

| Distribution  | Manager | Tmux | Neovim | Ripgrep |
|---------------|---------|------|--------|---------|
| Debian/Ubuntu | apt     | ✅   | ✅     | ✅      |
| Alpine Linux  | apk     | ✅   | ✅     | ✅      |
| RHEL/CentOS   | yum     | ✅   | ✅     | ✅      |
| Fedora        | dnf     | ✅   | ✅     | ✅      |
| Arch Linux    | pacman  | ✅   | ✅     | ✅      |
| OpenSUSE      | zypper  | ✅   | ✅     | ✅      |

## Repo structure

```
.
├── README.md
├── src/
│   ├── tmux/
│   │   ├── devcontainer-feature.json    # Metadata and options
│   │   ├── install.sh                   # Install script
│   │   ├── README.md
│   │   └── .tmux.conf.example
│   ├── neovim/
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── README.md
│   └── ripgrep/
│       ├── devcontainer-feature.json
│       ├── install.sh
│       ├── README.md
│       └── .ripgreprc.example
└── .github/
    └── workflows/
        └── release.yaml                 # Publishes to GHCR
```

## Creating new features

### 1. Create the directory

```bash
mkdir -p src/my-feature
```

### 2. Create `devcontainer-feature.json`

```json
{
  "id": "my-feature",
  "version": "1.0.0",
  "name": "My Feature",
  "description": "Feature description",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Version to install"
    }
  }
}
```

### 3. Create `install.sh`

```bash
#!/bin/bash
set -e

# Your install logic here
# Detect system, install the tool, validate the install
```

Make it executable: `chmod +x src/my-feature/install.sh`

### 4. Create `README.md`

Document what it does, how to use it, options, useful commands, and troubleshooting.

### 5. Publish

Bump `version` in `devcontainer-feature.json`, commit + push, and create a release. The workflow will publish it to `ghcr.io/oimoralest/features/my-feature`.

## Best practices

- Auto-detect the distribution and package manager
- Use `set -e` in `install.sh` to fail fast
- Validate that the install succeeded before exiting
- Expose configurable options via `options` in the JSON
- Include example config files
- Document everything in the feature's README

## Troubleshooting

### Feature won't download

- Make sure the GHCR package is public (packages are private by default even if the repo is public)
- Verify the exact tag: `ghcr.io/oimoralest/features/tmux:1`

### Error during install

```bash
# Verify system detection inside the container
cat /etc/os-release
which apt-get apk yum dnf
```

Check the devcontainer rebuild logs — `install.sh` prints every step.

### Feature installs but the command isn't on PATH

```bash
which tmux nvim rg
echo $PATH
```

## Resources

- [Dev Container Features Specification](https://containers.dev/implementors/features/)
- [Feature Template](https://github.com/devcontainers/feature-template)
- [Feature Distribution](https://containers.dev/implementors/features-distribution/)
- [Official Features](https://containers.dev/features)
