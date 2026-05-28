#!/bin/bash

# Configurazione percorsi relativi stabili
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/archive_logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Variabili nomi file ottimizzate (Log espliciti e file temporaneo)
FILE_LOG_TEMP="nginx_access_${TIMESTAMP}_TEMP.log"
FILE_TAR_FINALE="nginx_logs_${TIMESTAMP}.tar.gz"

# Garantisco l'esistenza della cartella di destinazione
mkdir -p "$BACKUP_DIR"

echo "Estrazione log in corso dal container nginx-frontend..."

# 1. Estraggo unificando i canali (stdout + stderr) per non sporcare il terminale
sudo docker logs nginx-frontend > "$BACKUP_DIR/$FILE_LOG_TEMP" 2>&1

# 2. Archivio e comprimo in formato tar.gz
tar -czf "$BACKUP_DIR/$FILE_TAR_FINALE" -C "$BACKUP_DIR" "$FILE_LOG_TEMP"

# 3. Pulizia: elimino il file temporaneo
rm "$BACKUP_DIR/$FILE_LOG_TEMP"

echo "Backup completato con successo: $BACKUP_DIR/$FILE_TAR_FINALE"