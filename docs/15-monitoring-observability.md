# 15. MONITORING AND OBSERVABILITY

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# OpenShift built-in monitoring exists but RHOSO telemetry components, Prometheus rules, Thanos, Gnocchi/Ceilometer/Aodh and exporters may be optional and version-specific.

# [OCP][RO] Inspect cluster monitoring operator
oc get co monitoring

# [OCP][RO] List OpenShift monitoring pods
oc get pods -n openshift-monitoring

# [OCP][RO] Find user-workload monitoring config
oc get configmaps -n openshift-user-workload-monitoring

# [OCP][RO] Discover Prometheus resources
oc get prometheus -A

# [OCP][RO] Discover Alertmanager resources
oc get alertmanager -A

# [OCP][RO] Discover ServiceMonitors
oc get servicemonitors -A

# [OCP][RO] Discover PodMonitors
oc get podmonitors -A

# [OCP][RO] Discover PrometheusRules
oc get prometheusrules -A

# [OCP][RO] Discover ThanosRulers
oc get thanosrulers -A

# [OCP][RO] Discover RHOSO Telemetry CRDs and active operators
oc api-resources --verbs=list | grep -Ei "telemetry|ceilometer|aodh|gnocchi|autoscal|prometheus"

# [OCP][RO] List RHOSO telemetry-related pods
oc get pods -n "${NS}" | grep -Ei "telemetry|ceilometer|aodh|gnocchi|metrics|exporter"

# [OCP][RO] Inspect node CPU/memory consumption
oc adm top nodes

# [OCP][RO] Inspect per-container CPU/memory consumption
oc adm top pods -n "${NS}" --containers

# [OCP][RO] Inspect persistent volume usage/capacity
oc get pvc -n "${NS}" -o wide

# [OS][RO] Inspect hypervisor memory and CPU capacity
openstack hypervisor stats show

# [OS][RO] Inspect Placement allocation provider usage
openstack resource provider usage show "${RESOURCE_PROVIDER_UUID}"

# [OCP][RO] Inspect queue pressure and memory
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues name messages_ready messages_unacknowledged memory

# [OCP][RO] Inspect Galera max/current connections
oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Threads_connected'; SHOW GLOBAL VARIABLES LIKE 'max_connections';"

# [EDPM][RO] Inspect network throughput counters on host
ip -s link show "${NIC}"

# [EDPM][RO] Inspect compute disk I/O load
iostat -xz 1 3

# [CEPH][RO] Inspect Ceph aggregate health and storage usage
ceph -s && ceph df

# [OCP][RO] Inspect bounded namespace events
oc get events -n "${NS}" --sort-by=.lastTimestamp

# [OCP][RO] Collect UTC timestamp for incident correlation
date -u +%Y-%m-%dT%H:%M:%SZ
```