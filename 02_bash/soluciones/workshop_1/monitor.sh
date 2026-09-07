#!/bin/bash
# Monitor basico del contenedor - Taller 1, Parte 3
# Uso: ./monitor.sh   (no requiere argumentos)

UMBRAL=80  
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

PROCS=$(( $(ps aux | wc -l) - 1 ))
echo "Cantidad aproximada de procesos activos: $PROCS"

echo
echo "===== REVISION DE UMBRAL (${UMBRAL}%) ====="

df -h --output=pcent,target 2>/dev/null | tail -n +2 | while read -r pcent target; do
    valor=${pcent%\%}
    if [ "$valor" -ge "$UMBRAL" ] 2>/dev/null; then
        echo "ADVERTENCIA: la particion $target esta al ${valor}% (supera ${UMBRAL}%)"
    fi
done

echo
echo "===== FIN DEL REPORTE ====="
echo "Diagnostico terminado correctamente."
