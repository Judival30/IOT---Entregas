#!/bin/bash
# Desafio - Taller 1, Parte 1
# Detecta situacion sospechosa: un mismo usuario con 2 o mas eventos ERROR.
# Uso: ./sospechoso.sh [archivo]   (por defecto access.log)

LOG="${1:-access.log}"

if [ ! -f "$LOG" ]; then
    echo "ERROR: no existe el archivo '$LOG'"
    exit 1
fi

sospechosos=$(grep 'ERROR' "$LOG" \
    | awk '{for(i=1;i<=NF;i++) if($i ~ /^user=/) print $i}' \
    | sort | uniq -c \
    | awk '$1 >= 2 {print $2" -> "$1" errores"}')

if [ -n "$sospechosos" ]; then
    echo "ALERTA: actividad potencialmente sospechosa detectada"
    echo "$sospechosos"
    exit 2
else
    echo "OK: ningun usuario supera el umbral de 2 errores"
    exit 0
fi
