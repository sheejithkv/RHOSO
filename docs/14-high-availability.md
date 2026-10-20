# 14. HIGH AVAILABILITY ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Inspect both desired replicas AND ready endpoints; HA is proven only by controlled failure-domain tests under an approved plan. No disruptive failover tests are embedded here.

# [OCP][RO] Inspect deployed control plane replicas
oc get deploy,sts -n "${NS}" -o wide

# [OCP][RO] Inspect pod distribution by nodes
oc get pods -n "${NS}" -o wide

# [OCP][RO] Inspect service anti-affinity and spreading
oc get statefulset -n "${NS}" "${STATEFULSET}" -o json | jq '.spec.template.spec | {affinity,topologySpreadConstraints}'

# [OCP][RO] Inspect configured disruption budgets
oc get pdb -n "${NS}" -o wide

# [OCP][RO] Inspect RabbitMQ replicas and readiness
oc get rabbitmq -n "${NS}" --show-labels

# [OCP][RO] Inspect Galera replicas and readiness
oc get galera -n "${NS}" -o wide

# [OCP][RO] Inspect OVN NB/SB member pods and placement
oc get pods -n "${NS}" -o wide | grep -E "ovsdbserver-(nb|sb)"

# [OCP][RO] Inspect OVN gateways through Chassis and Port_Binding
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Chassis

# [OS][RO] Inspect Nova conductor state
openstack compute service list --service nova-conductor

# [OS][RO] Inspect Nova scheduler state
openstack compute service list --service nova-scheduler

# [OS][RO] Inspect hypervisor health
openstack hypervisor list

# [OCP][RO] Inspect API endpoint redundancy configuration
oc get services,routes -n "${NS}" -o wide

# [OCP][RO] Inspect service EndpointSlice backends
oc get endpointslices -n "${NS}" -o wide

# [OCP][RO] Inspect LoadBalancer service addresses
oc get svc -n "${NS}" -o wide | grep LoadBalancer

# [OCP][RO] Inspect storage resiliency via PVC topology
oc get pvc,pv -n "${NS}" -o wide

# [OCP][RO] Inspect node availability for anti-affinity capacity
oc get nodes -o wide
```