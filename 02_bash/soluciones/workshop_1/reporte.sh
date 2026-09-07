#!/bin/bash


LOG="access.log"
OUT="reporte.txt"

total=$(wc -l < "$LOG")
errores=$(grep -c 'ERROR' "$LOG")
warnings=$(grep -c 'WARN' "$LOG")

usuario_top=$(grep 'ERROR' "$LOG" \
    | awk '{for(i=1;i<=NF;i++) if($i ~ /^user=/) print $i}' \
    | sort | uniq -c | sort -nr | head -1 | awk '{print $2" ("$1" errores)"}')

ip_top=$(grep 'ERROR' "$LOG" \
    | awk '{for(i=1;i<=NF;i++) if($i ~ /^ip=/) print $i}' \
    | sort | uniq -c | sort -nr | head -1 | awk '{print $2" ("$1" errores)"}')

{
    echo "===== REPORTE DE ANALISIS DE $LOG ====="
    echo "Generado: $(date)"
    echo
    echo "1. Cantidad total de registros : $total"
    echo "2. Cantidad de errores         : $errores"
    echo "3. Cantidad de advertencias    : $warnings"
    echo "4. Usuario con mas errores     : $usuario_top"
    echo "5. IP con mas errores          : $ip_top"
} > "$OUT"

cat "$OUT"
