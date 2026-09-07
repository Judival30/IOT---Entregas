#!/bin/bash

uso() {
    echo "Uso: $0 <archivo> [archivo2 ...]"
    echo "Ejemplo: $0 access.log"
}


if [ "$#" -lt 1 ]; then
    echo "ERROR: no se proporciono ningun argumento."
    uso
    exit 1
fi

analizar_archivo() {
    local archivo="$1"

    if [ ! -f "$archivo" ]; then
        echo "ERROR: el archivo '$archivo' no existe."
        return 1
    fi

    echo "=============================================="
    echo "Archivo analizado : $archivo"
    echo "Lineas            : $(wc -l < "$archivo")"
    echo "Palabras          : $(wc -w < "$archivo")"
    echo "Caracteres        : $(wc -c < "$archivo")"
    echo "Lineas con ERROR  : $(grep -c 'ERROR' "$archivo")"
    echo "Lineas con WARN   : $(grep -c 'WARN' "$archivo")"
    echo "=============================================="
}

for archivo in "$@"; do
    analizar_archivo "$archivo"
done
