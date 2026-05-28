#!/bin/bash
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Obtener opciones del feature
VERSION=${VERSION:-"latest"}
INSTALL_PLUGIN_MANAGER=${INSTALLPLUGINMANAGER:-"false"}

echo -e "${GREEN}=== Instalando Tmux ===${NC}"
echo "Versión solicitada: $VERSION"
echo "Instalar TPM: $INSTALL_PLUGIN_MANAGER"

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

# Instalar tmux según el gestor de paquetes
install_tmux() {
    local pkg_manager=$1
    
    echo -e "${YELLOW}Detectado gestor de paquetes: $pkg_manager${NC}"
    
    case "$pkg_manager" in
        apt)
            echo "Actualizando repositorios apt..."
            apt-get update
            echo "Instalando tmux..."
            DEBIAN_FRONTEND=noninteractive apt-get install -y tmux
            ;;
        apk)
            echo "Actualizando índice de paquetes apk..."
            apk update
            echo "Instalando tmux..."
            apk add --no-cache tmux
            ;;
        yum)
            echo "Instalando tmux con yum..."
            yum install -y tmux
            ;;
        dnf)
            echo "Instalando tmux con dnf..."
            dnf install -y tmux
            ;;
        pacman)
            echo "Actualizando base de datos de pacman..."
            pacman -Sy --noconfirm
            echo "Instalando tmux..."
            pacman -S --noconfirm tmux
            ;;
        zypper)
            echo "Instalando tmux con zypper..."
            zypper install -y tmux
            ;;
        *)
            echo -e "${RED}Error: Gestor de paquetes no soportado o no detectado${NC}"
            echo "Por favor instala tmux manualmente"
            exit 1
            ;;
    esac
}

# Instalar TPM (Tmux Plugin Manager)
install_tpm() {
    local target_user=${REMOTE_USER:-${USERNAME:-vscode}}
    local user_home
    
    # Detectar el directorio home del usuario
    if [ "$target_user" = "root" ]; then
        user_home="/root"
    else
        user_home="/home/$target_user"
    fi
    
    echo -e "${YELLOW}Instalando TPM para usuario: $target_user${NC}"
    echo "Directorio home: $user_home"
    
    # Instalar git si no está disponible
    if ! command -v git &> /dev/null; then
        echo "Git no encontrado, instalando..."
        local pkg_manager=$(detect_package_manager)
        case "$pkg_manager" in
            apt)
                apt-get update && apt-get install -y git
                ;;
            apk)
                apk add --no-cache git
                ;;
            yum|dnf)
                $pkg_manager install -y git
                ;;
            pacman)
                pacman -S --noconfirm git
                ;;
            zypper)
                zypper install -y git
                ;;
        esac
    fi
    
    # Crear directorio y clonar TPM
    local tpm_dir="$user_home/.tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        echo "TPM ya está instalado en $tpm_dir"
    else
        echo "Clonando TPM..."
        mkdir -p "$user_home/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        
        # Ajustar permisos si no es root
        if [ "$target_user" != "root" ]; then
            chown -R "$target_user:$target_user" "$user_home/.tmux"
        fi
        
        echo -e "${GREEN}TPM instalado en $tpm_dir${NC}"
        echo -e "${YELLOW}Para usar TPM, agrega esto a tu ~/.tmux.conf:${NC}"
        echo ""
        echo "# List of plugins"
        echo "set -g @plugin 'tmux-plugins/tpm'"
        echo "set -g @plugin 'tmux-plugins/tmux-sensible'"
        echo ""
        echo "# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)"
        echo "run '~/.tmux/plugins/tpm/tpm'"
        echo ""
        echo -e "${YELLOW}Luego presiona prefix + I (mayúscula i) para instalar plugins${NC}"
    fi
}

# Detectar información del sistema
DISTRO=$(detect_distro)
PKG_MANAGER=$(detect_package_manager)

echo -e "${YELLOW}Sistema detectado:${NC}"
echo "  Distribución: $DISTRO"
echo "  Gestor de paquetes: $PKG_MANAGER"
echo ""

# Verificar si tmux ya está instalado
if command -v tmux &> /dev/null; then
    CURRENT_VERSION=$(tmux -V | cut -d' ' -f2)
    echo -e "${YELLOW}Tmux ya está instalado (versión $CURRENT_VERSION)${NC}"
    if [ "$VERSION" = "latest" ]; then
        echo "Continuando con la versión existente..."
    else
        echo "Nota: Para instalar una versión específica, necesitarías compilar desde fuentes"
    fi
else
    # Instalar tmux
    install_tmux "$PKG_MANAGER"
    
    # Verificar instalación
    if command -v tmux &> /dev/null; then
        INSTALLED_VERSION=$(tmux -V)
        echo -e "${GREEN}✓ Tmux instalado exitosamente: $INSTALLED_VERSION${NC}"
    else
        echo -e "${RED}✗ Error: Tmux no se pudo instalar correctamente${NC}"
        exit 1
    fi
fi

# Instalar TPM si se solicitó
if [ "$INSTALL_PLUGIN_MANAGER" = "true" ]; then
    install_tpm
fi

echo ""
echo -e "${GREEN}=== Instalación de Tmux completada ===${NC}"
echo ""
echo "Comandos útiles de tmux:"
echo "  tmux           - Iniciar nueva sesión"
echo "  tmux ls        - Listar sesiones"
echo "  tmux attach    - Conectar a última sesión"
echo "  Ctrl+b ?       - Ver ayuda de atajos"
echo ""
