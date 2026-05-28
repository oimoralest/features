# Tmux Feature

Custom feature for installing tmux in devcontainers with automatic Linux distribution detection.

## Features

- ✅ **Automatic detection** of Linux distribution (Debian/Ubuntu, Alpine, RHEL/CentOS, Arch, SUSE)
- ✅ **Multiple package managers** supported (apt, apk, yum, dnf, pacman, zypper)
- ✅ **Optional install** of TPM (Tmux Plugin Manager)
- ✅ **Colored messages** for better visibility during install
- ✅ **Post-install validation** runs automatically

## Usage

### Basic configuration

In your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/oimoralest/features/tmux:1": {}
  }
}
```

### Configuration with options

```json
{
  "features": {
    "ghcr.io/oimoralest/features/tmux:1": {
      "version": "latest",
      "installPluginManager": true
    }
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | tmux version (currently only supports "latest" from repos) |
| `installPluginManager` | boolean | `false` | Install TPM (Tmux Plugin Manager) |

## Supported distributions

- **Debian/Ubuntu** (apt-get)
- **Alpine Linux** (apk)
- **RHEL/CentOS** (yum)
- **Fedora** (dnf)
- **Arch Linux** (pacman)
- **OpenSUSE** (zypper)

## TPM (Tmux Plugin Manager)

If you enable `installPluginManager: true`, TPM will be installed automatically. To use it:

1. Create or edit `~/.tmux.conf`:

```bash
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Add more plugins here
# set -g @plugin 'tmux-plugins/tmux-resurrect'

# Initialize TPM (keep this line at the end of the file)
run '~/.tmux/plugins/tpm/tpm'
```

2. Reload tmux:
```bash
tmux source ~/.tmux.conf
```

3. Install plugins by pressing: `Ctrl+b` then `I` (capital i)

## Useful tmux commands

```bash
# Start a new session
tmux

# Start a named session
tmux new -s my-session

# List sessions
tmux ls

# Attach to last session
tmux attach

# Attach to a specific session
tmux attach -t my-session

# Kill a session
tmux kill-session -t my-session

# View keyboard shortcuts
Ctrl+b ?
```

## Feature structure

```
src/tmux/
├── devcontainer-feature.json  # Metadata and options
├── install.sh                 # Install script
└── README.md                  # This documentation
```

## How it works

1. **System detection**: The script auto-detects the distribution using `/etc/os-release` and other system files
2. **Package manager detection**: Identifies which package manager is available
3. **Adaptive install**: Uses the appropriate command for the detected manager
4. **Verification**: Confirms tmux was installed correctly
5. **Optional TPM**: If requested, installs and configures TPM

## Troubleshooting

### The script doesn't detect my distribution

The script should work with most modern Linux distributions. If you run into issues:

```bash
# See which distribution is detected
cat /etc/os-release

# See which package manager is available
which apt-get apk yum dnf pacman zypper
```

### Tmux didn't install correctly

Check the devcontainer logs during creation. The script prints colored messages indicating each step.

## Contributing

To improve this feature:

1. Edit `install.sh` to add support for more distributions
2. Update `devcontainer-feature.json` to add new options
3. Document changes in this README

## Resources

- [Tmux Wiki](https://github.com/tmux/tmux/wiki)
- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Dev Container Features](https://containers.dev/features)
