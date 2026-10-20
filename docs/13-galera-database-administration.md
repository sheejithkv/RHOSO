# 13. GALERA DATABASE ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Galera root account is managed by MariaDBAccount CR; Galera .status.rootDatabaseSecret identifies secret. Never dump secret or use mysql -pPASSWORD. Connect interactively with mysql -u root -p and obtain password using separately approved vault method. For unattended checks prefer Operator CR readiness when privileged SQL is unavailable.

# [OCP][RO] List all Galera CRs and topology
oc get galera -A

# [OCP][RO] List MariaDBAccount CRs
oc get mariadbaccounts -A

# [OCP][RO] Inspect Galera reconciliation conditions
oc describe galera -n "${NS}" "${GALERA_CR}"

# [OCP][RO] Discover root database credential SECRET NAME only
oc get galera -n "${NS}" "${GALERA_CR}" -o 'jsonpath={.status.rootDatabaseSecret}{"\n"}'

# [OCP][RO] Find Galera pods across service-specific cells
oc get pods -n "${NS}" -o wide | grep -i galera

# [OCP][RO] List containers in selected Galera pod
oc get pod -n "${NS}" "${GALERA_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# [OCP][RO] Connect interactively as DBA (password prompted, not CLI/history; must be authorized)
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p

# [OCP][RO] Read wsrep cluster membership; interactive password prompt
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size';"

# [OCP][RO] Read Galera primary component status
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status';"

# [OCP][RO] Read local sync state
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment';"

# [OCP][RO] Check node readiness to accept writes
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_ready';"

# [OCP][RO] Read Galera replication connectivity
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_connected';"

# [OCP][RO] Inspect current database process list (may contain query data)
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW PROCESSLIST;"

# [OCP][RO] Inspect DB connections and maximum capacity
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Threads_connected'; SHOW GLOBAL VARIABLES LIKE 'max_connections';"

# [OCP][RO] List database schemas
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW DATABASES;"

# [OCP][RO] Inspect logical database disk utilization from schema table
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SELECT table_schema,ROUND(SUM(data_length+index_length)/1024/1024,1) AS MiB FROM information_schema.tables GROUP BY table_schema;"

# [OCP][RO] Inspect Galera cluster logs
oc logs -n "${NS}" "${GALERA_POD}" -c "${GALERA_CONTAINER}" --since=1h

# [OCP][RO] Inspect Galera PVC volume attachment and storage
oc get pvc -n "${NS}" -o wide | grep -i galera

# [OCP][RO] Inspect database backup-related scheduled jobs; backup implementation is site dependent
oc get cronjobs,jobs -n "${NS}" | grep -Ei "backup|maria|galera"
```