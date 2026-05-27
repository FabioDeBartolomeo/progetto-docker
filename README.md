# Infrastruttura a due livelli Isolata con Docker Compose

## Descrizione del Progetto
Questo laboratorio implementa un'architettura infrastrutturale a due livelli (Two-Tier) standard del settore, mirata alla segregazione dei ruoli e alla persistenza dei dati, minimizzando la superficie di attacco esterna.

L'ambiente è composto da:
1. **Front-end (Web Server):** Un container Nginx esposto sulla porta standard HTTP (80) dell'host.
2. **Back-end (Database):** Un container MySQL 8.0 completamente isolato dall'esterno.

## Architettura di Rete e Sicurezza
* **Segregazione:** I container comunicano all'interno di una rete virtuale isolata con driver `bridge` (`backend-net`).
* **Isolamento del DB:** La porta nativa di MySQL (`3306`) e la porta del protocollo X (`33060`) **non sono mappate** verso l'host. Il database è accessibile esclusivamente dal container Nginx tramite risoluzione DNS interna di Docker, azzerando i vettori di attacco diretti dall'esterno.

## Gestione dello Storage e Persistenza
I dati del database sono protetti tramite un volume logico locale (`db-data`) mappato direttamente sulla directory di sistema `/var/lib/mysql` del container. Questo garantisce la persistenza del dato anche in caso di distruzione, aggiornamento o manutenzione evolutiva del container stesso.

## Comandi Operativi (CLI)
Per l'amministrazione e il deployment dell'infrastruttura sono stati utilizzati i seguenti comandi da terminale Linux:

* **Avvio in background (Detached mode):**
  ```bash
  sudo docker compose up -d