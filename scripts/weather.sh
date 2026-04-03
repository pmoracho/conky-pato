#!/bin/bash

#==============================================================================
# Weather Fetcher v3.0 - Pato
# Basado en el trabajo de Closebox73
#==============================================================================

CITY_ID="3430310"                                # Olivos, AR
API_KEY="<ingresar tu API Key>"   
UNITS="metric"
LANG="es"

# --- RUTAS ---
CACHE_DIR="$HOME/.cache/weather_conky"
JSON_FILE="$CACHE_DIR/weather.json"
ICON_DIR="$CACHE_DIR/icons"
CURRENT_ICON="$CACHE_DIR/weather_icon.png"

# --- PARÁMETROS ---
VERBOSE=false
for arg in "$@"; do
    if [[ "$arg" == "-v" || "$arg" == "--verbose" ]]; then
        VERBOSE=true
    fi
done

log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

# --- MAIN ---
mkdir -p "$ICON_DIR"

URL="https://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=${UNITS}&lang=${LANG}"

if ! curl -s "$URL" -o "$JSON_FILE"; then
    log "Error: No se pudo descargar el JSON."
    exit 1
fi

log "JSON descargado: $JSON_FILE"

ICON_CODE=$(jq -r '.weather[0].icon // empty' "$JSON_FILE")

if [[ -z "$ICON_CODE" ]]; then
    log "Error: No se pudo extraer el ICON_CODE."
    exit 1
fi

FINAL_ICON_PATH="$ICON_DIR/${ICON_CODE}.png"
log "ICON_CODE: $ICON_CODE → $FINAL_ICON_PATH"

if [[ ! -f "$FINAL_ICON_PATH" ]]; then
    ICON_URL="https://openweathermap.org/img/wn/${ICON_CODE}@2x.png"
    log "Descargando icono: $ICON_CODE"
    curl -s "$ICON_URL" -o "$FINAL_ICON_PATH"
fi

cp "$FINAL_ICON_PATH" "$CURRENT_ICON"

log "Actualización completa para: $(jq -r '.name' "$JSON_FILE")"
