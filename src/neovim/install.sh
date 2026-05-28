#!/bin/bash
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION=${VERSION:-"stable"}

echo -e "${GREEN}=== Instalando Neovim ===${NC}"
echo "Versión solicitada: $VERSION"

# Detectar arquitectura
detect_arch() {
  local arch=$(uname -m)
  case "$arch" in
  x86_64)
    echo "linux-x86_64"
    ;;
  aarch64 | arm64)
    echo "linux-arm64"
    ;;
  *)
    echo -e "${RED}Arquitectura no soportada: $arch${NC}" >&2
    exit 1
    ;;
  esac
}

# Resolver versión
resolve_version() {
  local version=$1
  case "$version" in
  latest | stable)
    echo "stable"
    ;;
  nightly)
    echo "nightly"
    ;;
  *)
    if [[ ! "$version" =~ ^v ]]; then
      echo "v${version}"
    else
      echo "$version"
    fi
    ;;
  esac
}

# Descargar e instalar Neovim
install_neovim() {
  local version=$1
  local arch=$2

  echo -e "${BLUE}Descargando Neovim...${NC}"
  echo "Versión: $version | Arquitectura: $arch"

  local filename="nvim-${arch}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${version}/${filename}"

  echo "URL: $url"

  local temp_dir=$(mktemp -d)
  cd "$temp_dir"

  if ! curl -fsSL "$url" -o "$filename"; then
    echo -e "${RED}Error al descargar Neovim${NC}"
    cd - >/dev/null
    rm -rf "$temp_dir"
    return 1
  fi

  echo "Extrayendo..."
  tar xzf "$filename"

  local extracted_dir=$(find . -maxdepth 1 -type d -name "nvim-*" | head -n1)

  if [ -z "$extracted_dir" ]; then
    echo -e "${RED}Error: No se encontró el directorio extraído${NC}"
    cd - >/dev/null
    rm -rf "$temp_dir"
    return 1
  fi

  echo "Instalando en /usr/local..."
  cp -r "$extracted_dir/bin/"* /usr/local/bin/
  [ -d "$extracted_dir/lib" ] && cp -r "$extracted_dir/lib/"* /usr/local/lib/ 2>/dev/null || true
  [ -d "$extracted_dir/share" ] && cp -r "$extracted_dir/share/"* /usr/local/share/ 2>/dev/null || true
  chmod +x /usr/local/bin/nvim

  cd - >/dev/null
  rm -rf "$temp_dir"

  echo -e "${GREEN}Instalación completada${NC}"
}

ARCH=$(detect_arch)
RESOLVED_VERSION=$(resolve_version "$VERSION")

echo "Arquitectura: $ARCH"
echo "Versión resuelta: $RESOLVED_VERSION"

if ! install_neovim "$RESOLVED_VERSION" "$ARCH"; then
  echo -e "${RED}Error al instalar Neovim${NC}"
  exit 1
fi

if command -v nvim &>/dev/null; then
  echo ""
  echo -e "${GREEN}✓ Neovim instalado exitosamente${NC}"
  nvim --version | head -n1
  echo "Ubicación: $(which nvim)"
else
  echo -e "${RED}✗ Error: Neovim no se instaló correctamente${NC}"
  exit 1
fi
