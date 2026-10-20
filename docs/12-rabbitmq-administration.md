# 12. RABBITMQ ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# RHOSO uses RabbitMQ CRs and RabbitMQ Cluster Operator. Multiple clusters may exist, including per-cell. Discover pod and its actual container; rabbitmqctl and rabbitmq-diagnostics are standard utilities confirmed in RabbitMQ images but cluster-specific paths/config must be verified at runtime.

# [OCP][RO] List RHOSO RabbitMQ CR status
oc get rabbitmq -A --show-labels

# [OCP][RO] Inspect selected RabbitMQ CR readiness
oc describe rabbitmq -n "${NS}" "${RABBIT_CR}"

# [OCP][RO] Find RabbitMQ-related pods and cluster labeling
oc get pods -n "${NS}" -l app.kubernetes.io/name=rabbitmq -o wide --show-labels

# [OCP][RO] Discover containers in selected RabbitMQ pod
oc get pod -n "${NS}" "${RABBIT_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# [OCP][RO] Read RabbitMQ node cluster membership
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl cluster_status

# [OCP][RO] Read RabbitMQ node diagnostics
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmq-diagnostics status

# [OCP][RO] Inspect RabbitMQ node listeners
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmq-diagnostics listeners

# [OCP][RO] List RabbitMQ queues
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues

# [OCP][RO] Show per-queue depth/consumers/memory
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues name messages_ready messages_unacknowledged consumers memory

# [OCP][UNVERIFIED] Show quorum queue leader and members (requires installed RabbitMQ version with supported fields)
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues name type leader members online

# [OCP][RO] List established message broker connections
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_connections

# [OCP][RO] Inspect open RabbitMQ channels
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_channels

# [OCP][RO] Inspect RabbitMQ consumers
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_consumers

# [OCP][RO] Inspect alarm states
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmq-diagnostics alarms

# [OCP][RO] Inspect running RabbitMQ endpoints
oc get svc,endpointslices -n "${NS}" -l app.kubernetes.io/name=rabbitmq

# [OCP][RO] Inspect RabbitMQ pod logs
oc logs -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" --since=1h

# [OCP][RO] List RabbitMQ operator metadata
oc get deployments -n "${OPERATORS_NS}" | grep -i rabbit

# [OCP][RO] Inspect RabbitMQ users CRs if installed
oc get rabbitmquser -n "${NS}"
```