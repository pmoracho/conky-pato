#!/bin/bash

#==============================================================================
# install-fonts.sh - Instalador de fuentes para Conky Widget - Pato
#
# Descarga e instala Bebas Neue y Comfortaa desde Google Fonts.
# Las instala para el usuario actual (~/.local/share/fonts/).
#==============================================================================

set -e

FONT_DIR="$HOME/.local/share/fonts/conky-pato"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# URLs directas a los archivos .zip de Google Fonts
BEBAS_URL="https://fonts.google.com/download?family=Bebas+Neue"
COMFORTAA_URL="https://fonts.google.com/download?family=Comfortaa"

echo "==> Instalando fuentes para Conky Widget..."

# Verificar dependencias mínimas
for cmd in curl unzip fc-cache; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: '$cmd' no encontrado. Instalalo primero."
        exit 1
    fi
done

mkdir -p "$FONT_DIR"

install_font() {
    local name="$1"
    local url="$2"
    local zip="$TMP_DIR/${name}.zip"

    echo "  Descargando $name..."
    if ! curl -L --silent --show-error --max-time 30 "$url" -o "$zip"; then
        echo "  ERROR: No se pudo descargar $name."
        return 1
    fi

    echo "  Instalando $name..."
    unzip -o -q "$zip" "*.ttf" -d "$FONT_DIR/" 2>/dev/null || \
    unzip -o -q "$zip" -d "$TMP_DIR/${name}_extracted/" && \
        find "$TMP_DIR/${name}_extracted/" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;

    echo "  ✓ $name instalado"
}

install_font "BebasNeue"  "$BEBAS_URL"
install_font "Comfortaa"  "$COMFORTAA_URL"

# Actualizar caché de fuentes
echo "==> Actualizando caché de fuentes..."
fc-cache -f "$FONT_DIR"

echo ""
echo "✓ Fuentes instaladas en: $FONT_DIR"
echo ""
echo "  Fuentes disponibles:"
fc-list | grep -iE "bebas|comfortaa" | sort | sed 's/^/    /'
echo ""
echo "  Reiniciá Conky para aplicar los cambios:"
echo "    pkill conky; conky -c ~/.conkyrc &"
echo ""
