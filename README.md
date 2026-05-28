# Containerized Architecture & Infrastructure Automation

## Scopo del Progetto
Questo progetto documenta la configurazione di un ambiente infrastrutturale isolato (Sandbox) per dimostrare la transizione da una gestione sistemistica manuale a un modello orientato alle metodologie DevOps. Il focus è incentrato sull'isolamento di rete, la persistenza dello storage, l'iniezione dinamica dei dati a tempo di runtime e le politiche di log management su piattaforma Linux Debian.

---

## Architettura dei Servizi (Docker Compose)

L'infrastruttura è suddivisa in due livelli architetturali isolati tramite una rete bridge dedicata (backend-net):

* **Frontend (nginx-frontend):** Espone la porta HTTP 80 sul nodo ospitante. Serve la pagina di status dinamica. Configurato con un Bind Mount del file ./index.html in modalità sola lettura (:ro) per preservare l'integrità del container. Connesso alla rete backend-net.
* **Backend (mysql-enterprise):** Database relazionale MySQL 8.0. Completamente isolato dal traffico esterno (nessuna porta mappata sulla macchina host). Utilizza un Docker Volume gestito (db-data) per garantire la persistenza dei dati e la consistenza dello storage. Connesso alla rete backend-net.

---

## Logica delle Automazioni (/scripts)

### 1. Controllo Stack e Deploy Dinamico (manage-stack.sh)
Centralizza l'orchestrazione dei servizi ed evita la staticità dei dati applicativi nel frontend.
* **Funzionamento:** Prima di invocare il sollevamento dei container, lo script interroga direttamente il kernel dell'host ricavando l'indirizzo IP privato dell'interfaccia di rete e l'uptime di sistema. Tramite lo stream editor 'sed', inietta queste metriche reali nel file index.html.template, generando l'output index.html definitivo che verrà letto da Nginx all'avvio.
* **Uso:** ./scripts/manage-stack.sh {start|stop|status}

### 2. Log Retention e Lifecycle Management (backup-logs.sh)
Implementa le policy di sicurezza per prevenire la saturazione del disco sul nodo ospitante.
* **Funzionamento:** Intercetta ed estrae i flussi di output unificati (stdout e stderr tramite ridirezione 2>&1) dal container Nginx in produzione. Centralizza i dati in un file temporaneo, esegue la compressione in formato tar.gz applicando un timestamp sicuro per il file system (YYYY-MM-DD_HH-MM-SS) e sposta l'archivio finale nella directory archive_logs/, eseguendo il wipe dei dati temporanei.
* **Uso:** ./scripts/backup-logs.sh

---

## Strumenti di Analisi Log via CLI (Parsing di Rete)

Sintassi dei comandi nativi Linux utilizzati in console per attività di Auditing, Troubleshooting e verifica degli accessi:

* **Isolamento del traffico HTTP (Esclusione dei messaggi di sistema notice):**
  sudo docker logs nginx-frontend 2>&1 | grep "GET"

* **Estrazione ed elencazione degli indirizzi IP univoci dei client connessi:**
  sudo docker logs nginx-frontend 2>&1 | grep "GET" | awk '{print $1}' | sort -u