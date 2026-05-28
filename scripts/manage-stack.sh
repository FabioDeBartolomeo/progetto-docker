#!/bin/bash

# Definisco il percorso della cartella del progetto (un livello sopra la cartella script)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT_DIR" || exit 1

case "$1" in
    start)
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