#!/bin/bash

RUTA="${1:-/}"

if [ ! -e "$RUTA" ]; then
    echo "Error: la ruta '$RUTA' no existe"
    echo "Uso: $0 [ruta]"
    exit 1
fi

echo "Hostname: $(hostname)"
echo "Usuario: $(whoami)"
echo "Fecha: $(date)"
echo "Uptime:"
uptime

echo "Disco (raiz):"
df -h /

echo "Memoria:"
free -h

echo "Ruta analizada: $RUTA"
echo "Filesystem donde se encuentra la ruta:"
df -h "$RUTA"

echo "Tipo de filesystem:"
df -T "$RUTA" | tail -n 1 | awk '{print $2}'

echo "Espacio usado por la ruta:"
du -sh "$RUTA" 2>/dev/null
