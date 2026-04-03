#!/bin/bash

#==============================================================================
# install.sh - Instalador del Conky Widget de Pato
#==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.conky"
CACHE_DIR="$HOME/.cache/weather_conky"

echo "==> Instalando Conky Widget..."

# Instalar fuentes si el script existe
if [[ -f "$REPO_DIR/install-fonts.sh" ]]; then
    echo "==> Instalando fuentes..."
    bash "$REPO_DIR/install-fonts.sh"
fi

# Verificar dependencias
for cmd in conky jq curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: '$cmd' no está instalado. Instalalo con tu gestor de paquetes."
        exit 1
    fi
done
echo "    Dependencias OK: conky, jq, curl"

# Crear directorio de instalación
mkdir -p "$INSTALL_DIR"
mkdir -p "$CACHE_DIR/icons"

# Copiar archivos
cp "$REPO_DIR/conkyrc"           "$INSTALL_DIR/conkyrc"
cp "$REPO_DIR/scripts/weather.sh" "$INSTALL_DIR/scripts/weather.sh"
chmod +x "$INSTALL_DIR/scripts/weather.sh"

echo "    Archivos copiados a $INSTALL_DIR"

# Crear symlink ~/.conkyrc → ~/.conky/conkyrc
if [[ -f "$HOME/.conkyrc" && ! -L "$HOME/.conkyrc" ]]; then
    echo "    Backup de ~/.conkyrc → ~/.conkyrc.bak"
    mv "$HOME/.conkyrc" "$HOME/.conkyrc.bak"
fi
ln -sf "$INSTALL_DIR/conkyrc" "$HOME/.conkyrc"
echo "    Symlink creado: ~/.conkyrc → $INSTALL_DIR/conkyrc"

# Primera bajada del clima
echo "==> Descargando datos del clima por primera vez..."
bash "$INSTALL_DIR/scripts/weather.sh" -v

echo ""
echo "✓ Instalación completa."
echo ""
echo "  Para iniciar Conky:"
echo "    conky -c ~/.conkyrc &"
echo ""
echo "  IMPORTANTE: Editá API_KEY y CITY_ID en:"
echo "    $INSTALL_DIR/scripts/weather.sh"
echo ""
