#!/bin/bash

# Configurazione percorsi relativi stabili
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT_DIR" || exit 1

case "$1" in
    start)
        echo "Raccolta metriche dal nodo host..."
        HOST_IP=$(hostname -I | awk '{print $1}')
        HOST_UPTIME=$(uptime -p)

        echo "Generazione pagina index.html dinamica..."
        # Raddoppiate le graffe per intercettare il testo esatto del template
        sed -e "s|{{IP_PRIVATO}}|$HOST_IP|g" \
            -e "s|{{UPTIME}}|$HOST_UPTIME|g" \
            index.html.template > index.html

        echo "Avvio dell'infrastruttura in background..."
        sudo docker compose up -d
        ;;
    stop)
        echo "Arresto dell'infrastruttura..."
        sudo docker compose down
        ;;
    status)
        echo "Verifica stato dei container:"
        sudo docker compose ps
        ;;
    *)
        echo "Uso corretto: $0 {start|stop|status}"
        exit 1
        ;;
esac