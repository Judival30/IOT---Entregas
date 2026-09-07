#!/bin/bash
# Monitor basico del contenedor - reto integrador Taller 3
# Escribe una copia del reporte en /logs (volumen compartido con nginx)

UMBRAL=80
LOGDIR="/logs"
mkdir -p "$LOGDIR"
OUT="$LOGDIR/monitor_$(date +%Y%m%d_%H%M%S).log"

{
    echo "===== MONITOR DEL CONTENEDOR ====="
    echo "Hostname:   $(hostname)"
    echo "Usuario:    $(whoami)"
    echo "Fecha:      $(date)"
    echo "Directorio: $(pwd)"
    echo
    echo "===== DISCO ====="
    df -h
    echo
    echo "===== PROCESOS ====="
    echo "Procesos activos: $(( $(ps aux | wc -l) - 1 ))"
    echo
    echo "===== UMBRAL (${UMBRAL}%) ====="
    df -h --output=pcent,target 2>/dev/null | tail -n +2 | while read -r pcent target; do
        valor=${pcent%\%}
        if [ "$valor" -ge "$UMBRAL" ] 2>/dev/null; then
            echo "ADVERTENCIA: $target al ${valor}%"
        fi
    done
    echo
    echo "===== FIN DEL REPORTE ====="
} | tee "$OUT"

echo
echo "Reporte guardado en: $OUT"
