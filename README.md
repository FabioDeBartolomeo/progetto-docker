# Cloud Home Lab: Docker & Automation

## Scopo del Progetto
Questo laboratorio dimostra la transizione da una gestione infrastrutturale manuale a un modello automatizzato (DevOps), applicando i concetti di isolamento di rete, persistenza dello storage, iniezione dinamica dei dati e log management su ambiente Linux Debian.

---

## Architettura dei Servizi (Docker Compose)

L'infrastruttura è suddivisa in due livelli isolati tramite una rete bridge dedicata (backend-net):

* **Frontend (nginx-frontend):** Espone la porta 80. Serve la pagina di status dinamica. Configurato con un Bind Mount del file ./index.html in sola lettura (:ro). Connesso a backend-net.
* **Backend (mysql-enterprise):** Database MySQL 8.0. Isolato dall'esterno (nessuna porta esposta sulla macchina host). Utilizza un Docker Volume (db-data) per la persistenza dei dati. Connesso a backend-net.

---

## Logica delle Automazioni (/scripts)

### 1. Avvio Dinamico (manage-stack.sh)
Centralizza l'orchestrazione ed evita la staticità del frontend.
* **Cosa fa:** Prima di sollevare i container, interroga il kernel dell'host ricavando l'IP privato e l'uptime di sistema. Tramite sed, inietta questi dati reali nel file index.html.template generando l'output index.html definitivo letto da Nginx.
* **Uso:** ./scripts/manage-stack.sh {start|stop|status}

### 2. Retention dei Log (backup-logs.sh)
Previene la saturazione del disco isolando i log dai container.
* **Cosa fa:** Estrae i flussi unificati (stdout e stderr tramite 2>&1) da Nginx. Salva i dati in un file temporaneo, li comprime in un archivio tar.gz nominato con timestamp sicuro (YYYY-MM-DD_HH-MM-SS) e pulisce l'area di lavoro spostando l'archivio in archive_logs/.
* **Uso:** ./scripts/backup-logs.sh

---

## Comandi Utili per l'Analisi dei Log (CLI Parsing)

Filtri rapidi utilizzati in console per attività di Auditing e Troubleshooting:

* **Isolamento traffico HTTP (Esclusione avvisi di sistema):**
  sudo docker logs nginx-frontend 2>&1 | grep "GET"

* **Estrazione e conteggio degli IP univoci dei visitatori:**
  sudo docker logs nginx-frontend 2>&1 | grep "GET" | awk '{print $1}' | sort -u