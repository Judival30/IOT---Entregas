#!/bin/bash

echo -n "Ingrese el nombre del directorio: "
read dir

if [ ! -d "$dir" ]
then
    echo "Error: el directorio $dir no existe"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR directorio inexistente: $dir" >> backup.log
    exit 1
fi

mkdir -p backup
fecha=$(date +%Y%m%d_%H%M%S)
archivo="backup/$(basename "$dir")_$fecha.tar.gz"
tar -czf "$archivo" -C "$dir" .
codigo=$?

cantidad=$(tar -tzf "$archivo" | grep -v '/$' | wc -l)
tamano=$(du -h "$archivo" | cut -f1)

if [ $codigo -eq 0 ]
then
    estado="EXITO"
else
    estado="ERROR"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') $estado $archivo $cantidad archivos $tamano" >> backup.log

echo "===== Resumen del respaldo ====="
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Archivos respaldados: $cantidad"
echo "Tamano del respaldo: $tamano"
echo "Estado: $estado"
exit $codigo
