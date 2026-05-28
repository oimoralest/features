#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION=${VERSION:-"latest"}

echo -e "${GREEN}=== Installing Lazygit ===${NC}"
echo "Requested version: $VERSION"

detect_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
  x86_64)
    echo "x86_64"
    ;;
  aarch64 | arm64)
    echo "arm64"
    ;;
  armv6l | armv7l)
    echo "armv6"
    ;;
  *)
    echo -e "${RED}Unsupported architecture: $arch${NC}" >&2
    exit 1
    ;;
  esac
}

resolve_version() {
  local version=$1
  if [ "$version" = "latest" ]; then
    echo -e "${BLUE}Resolving latest version from GitHub...${NC}" >&2
    local latest
    latest=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
      | grep '"tag_name"' \
      | head -n1 \
      | sed 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/')
    if [ -z "$latest" ]; then
      echo -e "${RED}Failed to resolve latest version from GitHub API${NC}" >&2
      exit 1
    fi
    echo "$latest"
  else
    # Strip leading "v" if present (release tags use vX.Y.Z, archive names use X.Y.Z)
    echo "${version#v}"
  fi
}

install_lazygit() {
  local version=$1
  local arch=$2

  echo -e "${BLUE}Downloading Lazygit...${NC}"
  echo "Version: $version | Architecture: $arch"

  local filename="lazygit_${version}_Linux_${arch}.tar.gz"
  local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/${filename}"

  echo "URL: $url"

  local temp_dir
  temp_dir=$(mktemp -d)
  cd "$temp_dir"

  if ! curl -fsSL "$url" -o "$filename"; then
    echo -e "${RED}Failed to download Lazygit${NC}" >&2
    cd - >/dev/null
    rm -rf "$temp_dir"
    return 1
  fi

  echo "Extracting..."
  tar xzf "$filename" lazygit

  echo "Installing to /usr/local/bin..."
  install -m 0755 lazygit /usr/local/bin/lazygit

  cd - >/dev/null
  rm -rf "$temp_dir"

  echo -e "${GREEN}Install complete${NC}"
}

ARCH=$(detect_arch)
RESOLVED_VERSION=$(resolve_version "$VERSION")

echo "Architecture: $ARCH"
echo "Resolved version: $RESOLVED_VERSION"

if ! install_lazygit "$RESOLVED_VERSION" "$ARCH"; then
  echo -e "${RED}Failed to install Lazygit${NC}" >&2
  exit 1
fi

if command -v lazygit &>/dev/null; then
  echo ""
  echo -e "${GREEN}✓ Lazygit installed successfully${NC}"
  lazygit --version
  echo "Location: $(which lazygit)"
else
  echo -e "${RED}✗ Error: Lazygit did not install correctly${NC}" >&2
  exit 1
fi
