#!/bin/bash
# Analizador de texto - reto integrador Taller 3
# Uso: ./analiza.sh <archivo> [archivo2 ...]

uso() { echo "Uso: $0 <archivo> [archivo2 ...]"; }

if [ "$#" -lt 1 ]; then
    echo "ERROR: no se proporciono ningun argumento."
    uso
    exit 1
fi

for archivo in "$@"; do
    if [ ! -f "$archivo" ]; then
        echo "ERROR: el archivo '$archivo' no existe."
        continue
    fi
    echo "=============================================="
    echo "Archivo analizado : $archivo"
    echo "Lineas            : $(wc -l < "$archivo")"
    echo "Palabras          : $(wc -w < "$archivo")"
    echo "Caracteres        : $(wc -c < "$archivo")"
    echo "Lineas con ERROR  : $(grep -c 'ERROR' "$archivo")"
    echo "Lineas con WARN   : $(grep -c 'WARN' "$archivo")"
    echo "=============================================="
done
