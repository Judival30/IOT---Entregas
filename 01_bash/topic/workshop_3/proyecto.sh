#!/bin/bash

carpeta="respaldo_$(date +%Y-%m-%d)"
mkdir -p "$carpeta"
cp *.txt "$carpeta/" 2>/dev/null
codigo=$?
total=$(ls "$carpeta"/*.txt 2>/dev/null | wc -l)

{
    echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Carpeta: $carpeta"
    echo "Archivos copiados: $total"
    echo "Codigo de salida: $codigo"
} > reporte.log

if [ $codigo -eq 0 ]
then
    echo "Exito: se copiaron $total archivos a $carpeta"
else
    echo "Error: no se pudieron copiar archivos (codigo $codigo)"
    exit 1
fi
