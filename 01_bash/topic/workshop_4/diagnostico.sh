#!/bin/bash

archivo=${1:-logs.json}

echo "===== Informe de diagnostico ====="
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "--- Proceso con mayor consumo de CPU ---"
ps -eo user,pid,pcpu,pmem,comm --sort=-pcpu | awk 'NR>1 && $5!="ps" && $5!="awk" {print "Usuario:",$1,"PID:",$2,"CPU:",$3"%","MEM:",$4"%","Comando:",$5; exit}'
echo "--- Errores HTTP 500 ---"
total=$(jq -c 'select(.status==500)' "$archivo" | wc -l)
echo "Total: $total"
echo "--- Errores por servicio ---"
jq -r 'select(.status==500) | .service' "$archivo" | sort | uniq -c | sort -rn
echo "--- Mensajes de error ---"
jq -r 'select(.status==500) | "\(.service): \(.message)"' "$archivo"
