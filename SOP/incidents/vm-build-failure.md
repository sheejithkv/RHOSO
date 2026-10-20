# SOP-INC-001: VM stuck in BUILD or enters ERROR

| Field | Value |
| --- | --- |
| Status / version | DRAFT / 0.1.0 |
| Scope | RHOSO 18.x; Nova -> Placement -> Neutron -> Cinder/Glance -> EDPM compute |
| Execution | [OS] authenticated OpenStackClient; [OCP] control-plane shell |
| Owner / approver | To be assigned |
| Last site validation | Not performed |

## Transaction boundary

**Original transaction:** tenant requests server creation; Nova returns a server ID, then the instance remains BUILD or reaches ERROR. A successful create API response proves only request acceptance, not scheduling, port binding, image retrieval, block-device mapping, or VM boot.

Record project, region, request ID, instance UUID, client-side timestamp, observed state and which dependency was first to fail. Distinguish incident-time state from current condition.

## Read-only collector

Use discovered, authorized contexts; do not paste multiple contexts into one shell. Variables below must be supplied from ticket/CLI evidence, not guessed.

~~~bash
# [OCP][RO] Discover RHOSO namespaces and client/service pods.
oc get openstackcontrolplanes -A
oc get pods -A -o wide | grep -Ei 'openstackclient|nova|placement|neutron|cinder|glance'

# [OCP][RO] Use the discovered namespace/pod.
oc rsh -n "$RHOSO_NAMESPACE" "$CLIENT_POD"

# [OS][RO] Verify cloud identity and the exact failing VM.
openstack token issue
openstack server show "$VM_UUID" -f yaml

# [OS][RO] Retrieve instance actions and inventory without mutation.
openstack server event list "$VM_UUID"
openstack server list --all-projects --long
openstack compute service list
openstack hypervisor stats show
openstack resource provider list

# [OS][RO] Inspect related Neutron and block storage dependencies.
openstack port list --server "$VM_UUID"
openstack server volume list "$VM_UUID"
openstack image list --long

# [OCP][RO] Discover exact scheduler/conductor pod and its containers.
oc get pods -n "$RHOSO_NAMESPACE" -o wide
oc get pod -n "$RHOSO_NAMESPACE" "$NOVA_POD" -o jsonpath='{.spec.containers[*].name}'

# [OCP][RO] Correlate request ID and timestamp within the discovered container.
oc logs -n "$RHOSO_NAMESPACE" "$NOVA_POD" -c "$NOVA_CONTAINER" --timestamps --since=60m
~~~

## Evidence classification

- **PROVEN HEALTHY**: exact prior transaction stage completes successfully with matching request/instance ID.
- **PROVEN BROKEN**: earliest error in scheduler, conductor, Placement allocation, image fetch, port binding, volume mapping or compute host at incident time.
- **INFERENCE / HYPOTHESIS**: NoValidHost may indicate capacity, aggregate/AZ rules, flavor traits, PCI/NUMA, cell mapping or service state; it is not the root cause without matching evidence.
- **UNKNOWN**: missing trace, absent logs, RBAC gap or unsupported/disabled optional service.

## Fault-domain-specific next action

- Scheduler rejection: collect scheduler error and Placement provider inventory/traits/allocations; inspect requested flavor, AZ and aggregates.
- Compute unregistered/down: compare service list, hypervisors, cell host mappings (use discovered Nova conductor as described in [Nova reference](../../docs/05-nova-cells-compute-placement.md)) and EDPM nova-compute service logs.
- Port binding/DHCP: inspect the instance port and Neutron API errors; then OVN NB/SB binding and affected chassis, not the entire network stack by default.
- Image or volume error: trace matching Glance/Cinder request and backend logs before involving Ceph.

## Stop / remediation boundary

This SOP is intentionally read-only. **Do not retry server creation, delete a port/VM, change quotas, force service state, or restart Nova based solely on BUILD/ERROR.** Document controller ownership, first proven failure, minimal reviewed change, risk, rollback and the test that reproduces the **original VM provisioning transaction**. Escalate when evidence crosses into a different fault domain.