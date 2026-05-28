# Laboratorio Infrastrutturale: Docker Compose & Automation

Ambiente di laboratorio locale focalizzato sulla containerizzazione di un'architettura web/database ed automazione dei processi di gestione e manutenzione log tramite scripting Bash.

## Architettura dello Stack

L'infrastruttura è orchestrata tramite Docker Compose ed è composta da due servizi isolati in una rete dedicata:

* **Web Server (Frontend):** Container Nginx esposto sulla porta host 80. Gestisce le richieste web e serve una pagina di status dinamica. I dati sensibili dell'host (IP e Uptime) vengono iniettati nel container tramite bind mount in sola lettura (`:ro`).
* **Database (Backend):** Container MySQL enterprise isolato all'interno della rete interna (`backend-net`), non accessibile direttamente dall'esterno. La persistenza dei dati è garantita da un volume Docker gestito.

## Automazione e Gestione (Cartella `/scripts`)

Il ciclo di vita dell'infrastruttura e le operazioni di manutenzione sono completamente automatizzati tramite script in Bash:

### 1. Gestione dello Stack (`manage-stack.sh`)
Centralizza l'orchestrazione dei container e la manipolazione dinamica del frontend. 
* All'avvio (`start`), lo script raccoglie in tempo reale l'IP privato dell'interfaccia di rete dell'host e l'uptime di sistema, iniettandoli tramite `sed` all'interno del template HTML (`index.html.template`) prima di sollevare i container.
* Gestisce in modo nativo i comandi di interruzione (`stop`) e verifica stato (`status`).

Uso:
```bash
./scripts/manage-stack.sh {start|stop|status}