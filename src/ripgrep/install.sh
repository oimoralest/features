#!/bin/bash
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Obtener opciones del feature
VERSION=${VERSION:-"latest"}
INSTALL_FROM_GITHUB=${INSTALLFROMGITHUB:-"false"}

echo -e "${GREEN}=== Instalando Ripgrep (rg) ===${NC}"
echo "Versión solicitada: $VERSION"
echo "Instalar desde GitHub: $INSTALL_FROM_GITHUB"

# Función para detectar la distribución
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Función para detectar el gestor de paquetes
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v apk &> /dev/null; then
        echo "apk"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Función para detectar arquitectura
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        armv7l)
            echo "arm"
            ;;
        i686|i386)
            echo "i686"
            ;;
        *)
            echo "$arch"
            ;;
    esac
}

# Instalar dependencias necesarias
install_dependencies() {
    local pkg_manager=$1
    
    echo -e "${YELLOW}Instalando dependencias...${NC}"
    
    case "$pkg_manager" in
        apt)
            apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates
            ;;
        apk)
            apk add --no-cache curl ca-certificates
            ;;
        yum|dnf)
            $pkg_manager install -y curl ca-certificates
            ;;
        pacman)
            pacman -Sy --noconfirm curl ca-certificates
            ;;
        zypper)
            zypper install -y curl ca-certificates
            ;;
    esac
}

# Instalar ripgrep desde el gestor de paquetes
install_ripgrep_package_manager() {
    local pkg_manager=$1
    
    echo -e "${YELLOW}Detectado gestor de paquetes: $pkg_manager${NC}"
    
    case "$pkg_manager" in
        apt)
            echo "Actualizando repositorios apt..."
            apt-get update
            echo "Instalando ripgrep..."
            DEBIAN_FRONTEND=noninteractive apt-get install -y ripgrep
            ;;
        apk)
            echo "Actualizando índice de paquetes apk..."
            apk update
            echo "Instalando ripgrep..."
            apk add --no-cache ripgrep
            ;;
        yum)
            echo "Instalando ripgrep con yum..."
            # En RHEL/CentOS puede necesitar EPEL
            yum install -y ripgrep || {
                echo "Intentando habilitar EPEL..."
                yum install -y epel-release
                yum install -y ripgrep
            }
            ;;
        dnf)
            echo "Instalando ripgrep con dnf..."
            dnf install -y ripgrep
            ;;
        pacman)
            echo "Actualizando base de datos de pacman..."
            pacman -Sy --noconfirm
            echo "Instalando ripgrep..."
            pacman -S --noconfirm ripgrep
            ;;
        zypper)
            echo "Instalando ripgrep con zypper..."
            zypper install -y ripgrep
            ;;
        *)
            echo -e "${RED}Error: Gestor de paquetes no soportado: $pkg_manager${NC}"
            echo "Intentando instalación desde GitHub..."
            return 1
            ;;
    esac
}

# Instalar ripgrep desde GitHub releases
install_ripgrep_github() {
    local version=$1
    local arch=$(detect_arch)
    local distro=$(detect_distro)
    
    echo -e "${BLUE}Instalando ripgrep desde GitHub releases${NC}"
    echo "Arquitectura: $arch"
    
    # Si version es "latest", obtener la última versión
    if [ "$version" = "latest" ]; then
        echo "Obteniendo última versión de GitHub..."
        version=$(curl -sL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        if [ -z "$version" ]; then
            echo -e "${RED}No se pudo obtener la última versión de GitHub${NC}"
            return 1
        fi
        echo "Última versión disponible: $version"
    else
        # Asegurar que la versión tenga el prefijo 'v'
        if [[ ! "$version" =~ ^v ]]; then
            version="v${version}"
        fi
    fi
    
    # Determinar el formato del paquete según la distribución
    local package_ext
    local install_cmd
    
    case "$distro" in
        debian|ubuntu)
            package_ext="amd64.deb"
            if [ "$arch" = "aarch64" ]; then
                package_ext="arm64.deb"
            fi
            install_cmd="dpkg -i"
            ;;
        alpine)
            # Alpine usa musl
            package_ext="unknown-linux-musl.tar.gz"
            ;;
        *)
            # Por defecto usar el binario genérico de Linux
            package_ext="unknown-linux-musl.tar.gz"
            ;;
    esac
    
    # Construir URL de descarga
    local filename="ripgrep-${version#v}-${arch}-${package_ext}"
    local url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/${filename}"
    
    echo "Descargando desde: $url"
    
    # Descargar
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if ! curl -fsSL "$url" -o "$filename"; then
        echo -e "${YELLOW}Intentando con URL alternativa...${NC}"
        # Intentar con el tar.gz genérico
        filename="ripgrep-${version#v}-${arch}-unknown-linux-musl.tar.gz"
        url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/${filename}"
        echo "Descargando desde: $url"
        curl -fsSL "$url" -o "$filename" || {
            echo -e "${RED}Error al descargar ripgrep${NC}"
            cd -
            rm -rf "$temp_dir"
            return 1
        }
    fi
    
    # Instalar según el tipo de archivo
    if [[ "$filename" == *.deb ]]; then
        echo "Instalando paquete .deb..."
        dpkg -i "$filename"
    elif [[ "$filename" == *.tar.gz ]]; then
        echo "Extrayendo archivo tar.gz..."
        tar xzf "$filename"
        local extracted_dir=$(find . -maxdepth 1 -type d -name "ripgrep-*" | head -n1)
        if [ -n "$extracted_dir" ]; then
            echo "Copiando binario a /usr/local/bin..."
            cp "$extracted_dir/rg" /usr/local/bin/
            chmod +x /usr/local/bin/rg
            # Copiar manpage si existe
            if [ -f "$extracted_dir/doc/rg.1" ]; then
                mkdir -p /usr/local/share/man/man1
                cp "$extracted_dir/doc/rg.1" /usr/local/share/man/man1/
            fi
        else
            echo -e "${RED}Error: No se pudo encontrar el directorio extraído${NC}"
            cd -
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    # Limpiar
    cd -
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}Instalación desde GitHub completada${NC}"
}

# Detectar información del sistema
DISTRO=$(detect_distro)
PKG_MANAGER=$(detect_package_manager)
ARCH=$(detect_arch)

echo -e "${YELLOW}Sistema detectado:${NC}"
echo "  Distribución: $DISTRO"
echo "  Gestor de paquetes: $PKG_MANAGER"
echo "  Arquitectura: $ARCH"
echo ""

# Verificar si ripgrep ya está instalado
if command -v rg &> /dev/null; then
    CURRENT_VERSION=$(rg --version | head -n1 | cut -d' ' -f2)
    echo -e "${YELLOW}Ripgrep ya está instalado (versión $CURRENT_VERSION)${NC}"
    
    if [ "$INSTALL_FROM_GITHUB" = "true" ] && [ "$VERSION" != "latest" ]; then
        echo "Se solicitó una versión específica desde GitHub, procediendo con la instalación..."
    else
        echo "Continuando con la versión existente..."
        exit 0
    fi
fi

# Instalar ripgrep
if [ "$INSTALL_FROM_GITHUB" = "true" ]; then
    # Instalar desde GitHub
    install_dependencies "$PKG_MANAGER"
    if ! install_ripgrep_github "$VERSION"; then
        echo -e "${RED}Error al instalar desde GitHub${NC}"
        echo "Intentando con el gestor de paquetes..."
        install_ripgrep_package_manager "$PKG_MANAGER"
    fi
else
    # Instalar desde gestor de paquetes
    if ! install_ripgrep_package_manager "$PKG_MANAGER"; then
        echo -e "${YELLOW}Instalación desde gestor de paquetes falló${NC}"
        echo "Intentando instalación desde GitHub..."
        install_dependencies "$PKG_MANAGER"
        install_ripgrep_github "latest"
    fi
fi

# Verificar instalación
if command -v rg &> /dev/null; then
    INSTALLED_VERSION=$(rg --version | head -n1)
    echo ""
    echo -e "${GREEN}✓ Ripgrep instalado exitosamente${NC}"
    echo -e "${GREEN}  $INSTALLED_VERSION${NC}"
    echo ""
    echo "Ubicación: $(which rg)"
    echo ""
else
    echo -e "${RED}✗ Error: Ripgrep no se pudo instalar correctamente${NC}"
    exit 1
fi

echo -e "${GREEN}=== Instalación de Ripgrep completada ===${NC}"
echo ""
echo "Comandos útiles de ripgrep:"
echo "  rg 'patrón'              - Buscar patrón en archivos"
echo "  rg -i 'patrón'           - Búsqueda insensible a mayúsculas"
echo "  rg -t py 'patrón'        - Buscar solo en archivos Python"
echo "  rg -l 'patrón'           - Listar solo nombres de archivos"
echo "  rg --files               - Listar todos los archivos"
echo "  rg --help                - Ver ayuda completa"
echo ""
