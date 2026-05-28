# Ripgrep Feature

Custom feature for installing ripgrep (rg) in devcontainers with automatic Linux distribution detection.

## What is Ripgrep?

Ripgrep is an extremely fast command-line search tool that recursively searches directories for regex patterns. It's similar to `grep` but much faster and with better defaults.

## Features

- ✅ **Automatic detection** of Linux distribution (Debian/Ubuntu, Alpine, RHEL/CentOS, Arch, SUSE)
- ✅ **Multiple package managers** supported (apt, apk, yum, dnf, pacman, zypper)
- ✅ **Install from GitHub releases** for specific versions
- ✅ **Architecture detection** (x86_64, aarch64/arm64, armv7l, i686)
- ✅ **Automatic fallback** between install methods
- ✅ **Colored messages** for better visibility during install
- ✅ **Post-install validation** runs automatically

## Usage

### Basic configuration (from repositories)

In your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/oimoralest/features/ripgrep:1": {}
  }
}
```

### Configuration from GitHub (specific version)

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

### Configuration with options

```json
{
  "features": {
    "ghcr.io/oimoralest/features/ripgrep:1": {
      "version": "latest",
      "installFromGithub": false
    }
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `"latest"` | ripgrep version. Use "latest" for the repo version or specify a GitHub version (e.g. "14.1.0") |
| `installFromGithub` | boolean | `false` | If `true`, install from GitHub releases instead of the package manager |

## Supported distributions

- **Debian/Ubuntu** (apt-get) — .deb packages
- **Alpine Linux** (apk) — musl binaries
- **RHEL/CentOS** (yum) — with EPEL if needed
- **Fedora** (dnf)
- **Arch Linux** (pacman)
- **OpenSUSE** (zypper)

## Supported architectures

- **x86_64** (Intel/AMD 64-bit)
- **aarch64/arm64** (ARM 64-bit)
- **armv7l** (ARM 32-bit)
- **i686** (Intel/AMD 32-bit)

## Install strategy

The feature uses a smart fallback approach:

1. **Primary method**:
   - If `installFromGithub: false` → uses the package manager
   - If `installFromGithub: true` → uses GitHub releases

2. **Fallback method**:
   - If the primary method fails, automatically tries the alternative

This guarantees ripgrep is installed correctly even if one method isn't available.

## Useful Ripgrep commands

### Basic searches

```bash
# Search a pattern in the current directory
rg "function"

# Case-insensitive search
rg -i "function"

# Search whole word
rg -w "function"

# Search with regex
rg "func\w+"
```

### Filter by file type

```bash
# Search only in Python files
rg -t py "def "

# Search in multiple types
rg -t py -t js "import"

# Exclude file types
rg -T py "import"

# View available types
rg --type-list
```

### Output options

```bash
# Only show names of matching files
rg -l "pattern"

# Show non-matching lines
rg -v "pattern"

# Count matches per file
rg -c "pattern"

# Show context (3 lines before and after)
rg -C 3 "pattern"

# Only lines before
rg -B 3 "pattern"

# Only lines after
rg -A 3 "pattern"
```

### Advanced searches

```bash
# Search in specific files
rg "pattern" -g "*.py"

# Exclude directories
rg "pattern" -g "!node_modules/*"

# Find files containing some text
rg --files | rg "test"

# Replace text (preview only, doesn't modify)
rg "old" -r "new"

# Multiline search
rg -U "start.*\n.*end"

# Search in hidden files
rg --hidden "pattern"

# Follow symlinks
rg -L "pattern"
```

### Comparison with other commands

```bash
# Ripgrep (fast, smart)
rg "pattern"

# Equivalent with grep (slower)
grep -r "pattern" .

# Equivalent with find + grep (much slower)
find . -type f -exec grep "pattern" {} +
```

## Development usage examples

### Find imports

```bash
# Find all imports of a module
rg "import.*requests"

# Find imports of a specific package
rg "from mypackage import"
```

### Find definitions

```bash
# Find function definitions in Python
rg "^def \w+\("

# Find classes in Python
rg "^class \w+"

# Find async functions
rg "async def"
```

### Find TODOs and FIXMEs

```bash
# Find TODOs
rg "TODO|FIXME|XXX|HACK"

# Only in Python and JavaScript
rg -t py -t js "TODO"
```

### Code statistics

```bash
# Count how many Python files there are
rg --files -t py | wc -l

# Count lines of code (excluding tests)
rg -t py "^[^#]" -g "!test*" -c
```

## Advanced configuration

### Config file

You can create `~/.ripgreprc` for persistent configuration:

```bash
# Always use colors
--colors=line:fg:yellow
--colors=line:style:bold
--colors=path:fg:green
--colors=path:style:bold
--colors=match:fg:red
--colors=match:style:bold

# Smart-case search by default
--smart-case

# Follow symlinks
--follow

# Search in hidden files
--hidden

# Ignore certain directories
--glob=!.git/*
--glob=!node_modules/*
--glob=!.venv/*
--glob=!__pycache__/*
--glob=!*.pyc
```

Then export the variable:
```bash
export RIPGREP_CONFIG_PATH=~/.ripgreprc
```

## Integration with other tools

### Using with fzf (fuzzy finder)

```bash
# Interactive file search
rg --files | fzf

# Interactive content search
rg --line-number --color=always '' | fzf --ansi
```

### Using in scripts

```bash
#!/bin/bash
# Example: search and replace across multiple files

pattern="old_function"
replacement="new_function"

# Find files
files=$(rg -l "$pattern")

# Replace in each file
for file in $files; do
    sed -i "s/$pattern/$replacement/g" "$file"
    echo "Updated: $file"
done
```

## Troubleshooting

### The script doesn't detect my distribution

```bash
# See which distribution is detected
cat /etc/os-release

# See which package manager is available
which apt-get apk yum dnf pacman zypper
```

### Error installing from GitHub

If installing from GitHub fails:
- Check internet access
- Make sure curl is installed
- Try `installFromGithub: false` to use the package manager instead

### Ripgrep doesn't find certain files

By default, ripgrep:
- Ignores files in `.gitignore`
- Ignores hidden files
- Ignores binary files

To disable these behaviors:

```bash
# Search in hidden files
rg --hidden "pattern"

# Don't respect .gitignore
rg --no-ignore "pattern"

# Search in binary files
rg -a "pattern"

# All together
rg --hidden --no-ignore -a "pattern"
```

## Advantages over traditional grep

1. **Speed**: Much faster (uses Rust and is optimized)
2. **Smart**: Respects `.gitignore` by default
3. **Colors**: Colored output by default
4. **File types**: Easy filtering by file type
5. **Regex**: Modern regex support
6. **Usability**: Better defaults than grep

## Typical benchmarks

In a typical software project:
- **ripgrep**: ~0.5 seconds
- **ag (The Silver Searcher)**: ~1.5 seconds
- **ack**: ~3 seconds
- **grep -r**: ~5 seconds

## Feature structure

```
src/ripgrep/
├── devcontainer-feature.json  # Metadata and options
├── install.sh                 # Install script
└── README.md                  # This documentation
```

## Resources

- [Ripgrep repository](https://github.com/BurntSushi/ripgrep)
- [User guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [Comparison with other tools](https://github.com/BurntSushi/ripgrep#quick-examples-comparing-tools)

## Contributing

To improve this feature:

1. Edit `install.sh` to add more distributions or install methods
2. Update `devcontainer-feature.json` to add new options
3. Document changes in this README

## See also

- tmux feature: `ghcr.io/oimoralest/features/tmux:1`
- [Dev Container Features](https://containers.dev/features)
