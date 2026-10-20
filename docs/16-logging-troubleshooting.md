# 16. LOGGING, FORENSIC TROUBLESHOOTING AND MUST-GATHER

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Choose the original transaction first (request-id, instance UUID, volume UUID, port UUID) and collect a UTC time window. Commands below diagnose; no root cause is asserted from symptoms alone. Replace pod/container variables using earlier discovery. For RHOSO must-gather use Red Hat-supported registry image for matching release.

# [OCP][RO] Bounded pod log extraction
oc logs -n "${NS}" "${POD}" -c "${CONTAINER}" --since-time="${START_UTC}" --timestamps

# [OCP][RO] Previous crashed container logs
oc logs -n "${NS}" "${POD}" -c "${CONTAINER}" --previous --timestamps

# [OCP][RO] All-container pod logs
oc logs -n "${NS}" "${POD}" --all-containers=true --since=1h --timestamps

# [OCP][RO] Operator reconciliation errors
oc logs -n "${OPERATORS_NS}" deployment/"${OPERATOR_DEPLOYMENT}" --since=1h --all-containers=true

# [EDPM][RO] EDPM Nova Compute service logs
sudo journalctl -u "${NOVA_COMPUTE_UNIT}" --since "${SINCE}" --until "${UNTIL}" --no-pager

# [EDPM][RO] EDPM OVN controller journal
sudo journalctl -u "${OVN_CONTROLLER_UNIT}" --since "${SINCE}" --no-pager

# [EDPM][RO] EDPM libvirt daemon journal
sudo journalctl -u virtqemud --since "${SINCE}" --no-pager

# [EDPM][RO] EDPM networking logs
sudo journalctl -u NetworkManager --since "${SINCE}" --no-pager

# [EDPM][RO] EDPM kernel error messages
sudo journalctl -k --since "${SINCE}" -p warning --no-pager

# [EDPM][RO] EDPM selected guest libvirt log, if present
sudo journalctl --since "${SINCE}" -t libvirtd --no-pager

# [EDPM][RO] EDPM specific QEMU guest log (if available)
sudo tail -n 200 "/var/log/libvirt/qemu/${LIBVIRT_DOMAIN}.log"

# [OCP][RO] Nova API logs
oc logs -n "${NS}" "${NOVA_API_POD}" --all-containers=true --since=1h

# [OCP][RO] Nova scheduler logs
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" --all-containers=true --since=1h

# [OCP][RO] Nova conductor logs
oc logs -n "${NS}" "${NOVA_CONDUCTOR_POD}" --all-containers=true --since=1h

# [OCP][RO] Neutron API logs
oc logs -n "${NS}" "${NEUTRON_API_POD}" --all-containers=true --since=1h

# [OCP][RO] Cinder API logs
oc logs -n "${NS}" "${CINDER_API_POD}" --all-containers=true --since=1h

# [OCP][RO] Cinder Scheduler logs
oc logs -n "${NS}" "${CINDER_SCHEDULER_POD}" --all-containers=true --since=1h

# [OCP][RO] Cinder Volume logs (where pod-based)
oc logs -n "${NS}" "${CINDER_VOLUME_POD}" --all-containers=true --since=1h

# [OCP][RO] Glance API logs
oc logs -n "${NS}" "${GLANCE_API_POD}" --all-containers=true --since=1h

# [OCP][RO] Keystone API logs
oc logs -n "${NS}" "${KEYSTONE_API_POD}" --all-containers=true --since=1h

# [OCP][RO] OVN DB logs
oc logs -n "${NS}" "${OVN_NB_POD}" --all-containers=true --since=1h

# [OCP][RO] RabbitMQ logs
oc logs -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" --since=1h

# [OCP][RO] Galera logs
oc logs -n "${NS}" "${GALERA_POD}" -c "${GALERA_CONTAINER}" --since=1h

# [OCP][RO] Ansible jobs and status for failed EDPM deployment
oc get jobs,pods -n "${NS}" -l "openstackdataplanedeployment=${DP_DEPLOYMENT}"

# [OCP][RO] Correlate request ID in Nova API service logs
oc logs -n "${NS}" "${NOVA_API_POD}" --since=2h --all-containers=true | grep -F "${REQUEST_ID}"

# [OCP][RO] Correlate request ID in scheduler logs
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" --since=2h --all-containers=true | grep -F "${REQUEST_ID}"

# [OCP][RO] Collect default OCP must-gather to local directory; large read-only capture
oc adm must-gather --dest-dir="${MUST_GATHER_DIR}"

# [OCP][RO] Collect supported RHOSO-specific must-gather; confirm image version and scope first
oc adm must-gather --image=registry.redhat.io/rhoso-operators/openstack-must-gather-rhel9:1.0 --dest-dir="${RHOSO_GATHER_DIR}"

# [OCP][RO] INCIDENT 01 VM stuck BUILD: transaction = Nova create -> scheduler -> conductor -> compute -> Neutron/Glance/Placement. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 01: VM stuck BUILD | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 01 initial verification
openstack server show "${VM}" -c status -c fault -c OS-EXT-SRV-ATTR:host

# [OCP][RO] INCIDENT 01 relevant logs or fault-domain state
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" --since=1h --all-containers=true | grep -F "${REQUEST_ID}"

# [OS][RO] INCIDENT 01 conditional deeper boundary inspection
openstack server migration list --server "${VM}"

# [OCP][RO] INCIDENT 02 VM ERROR: transaction = Nova create/resize -> worker returned fault. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 02: VM ERROR | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 02 initial verification
openstack server show "${VM}" -f yaml

# [OCP][RO] INCIDENT 02 relevant logs or fault-domain state
oc logs -n "${NS}" "${NOVA_API_POD}" --since=1h --all-containers=true | grep -F "${REQUEST_ID}"

# [OS][RO] INCIDENT 02 conditional deeper boundary inspection
openstack port list --server "${VM}"

# [OCP][RO] INCIDENT 03 NoValidHost: transaction = scheduler allocation candidates -> Placement inventories and traits. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 03: NoValidHost | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 03 initial verification
openstack hypervisor stats show

# [OCP][RO] INCIDENT 03 relevant logs or fault-domain state
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" --since=1h --all-containers=true | grep -F "${REQUEST_ID}"

# [OS][RO] INCIDENT 03 conditional deeper boundary inspection
openstack resource provider list

# [OCP][RO] INCIDENT 04 Compute DOWN: transaction = nova-compute heartbeat -> RPC broker -> cell conductor. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 04: Compute DOWN | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 04 initial verification
openstack compute service list --host "${COMPUTE_HOST}"

# [EDPM][RO] INCIDENT 04 relevant logs or fault-domain state
sudo journalctl -u "${NOVA_COMPUTE_UNIT}" --since "${SINCE}" --no-pager

# [EDPM][RO] INCIDENT 04 conditional deeper boundary inspection
systemctl list-units --type=service --all --no-pager

# [OCP][RO] INCIDENT 05 Compute not registered: transaction = EDPM deployment -> compute service -> registration -> cell mapping. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 05: Compute not registered | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 05 initial verification
openstack compute service list --host "${COMPUTE_HOST}"

# [OCP][RO] INCIDENT 05 relevant logs or fault-domain state
oc logs -n "${NS}" job/"${ANSIBLE_JOB}" --since=2h --all-containers=true

# [OS][RO] INCIDENT 05 conditional deeper boundary inspection
openstack hypervisor list

# [OCP][RO] INCIDENT 06 Host missing from Nova cell: transaction = compute service register -> nova-manage cell host mapping. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 06: Host missing from Nova cell | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 06 initial verification
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts

# [OCP][RO] INCIDENT 06 relevant logs or fault-domain state
oc logs -n "${NS}" "${NOVA_CONDUCTOR_POD}" --since=2h --all-containers=true

# [OS][RO] INCIDENT 06 conditional deeper boundary inspection
openstack compute service list --host "${COMPUTE_HOST}"

# [OCP][RO] INCIDENT 07 VM DHCP failure: transaction = Neutron subnet DHCP -> OVN NB DHCP option -> SB binding -> guest packet. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 07: VM DHCP failure | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 07 initial verification
openstack port show "${PORT_ID}" -f yaml

# [OCP][RO] INCIDENT 07 relevant logs or fault-domain state
oc logs -n "${NS}" "${NEUTRON_API_POD}" --since=1h --all-containers=true

# [OCP][RO] INCIDENT 07 conditional deeper boundary inspection
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl list DHCP_Options

# [OCP][RO] INCIDENT 08 VM metadata unavailable: transaction = guest 169.254.169.254 -> OVN metadata proxy -> Nova metadata API. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 08: VM metadata unavailable | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 08 initial verification
openstack port show "${PORT_ID}" -f yaml

# [EDPM][RO] INCIDENT 08 relevant logs or fault-domain state
sudo podman logs --since 1h "${OVN_METADATA_CONTAINER}"

# [EDPM][RO] INCIDENT 08 conditional deeper boundary inspection
ip route get 169.254.169.254

# [OCP][RO] INCIDENT 09 VM external connectivity failure: transaction = guest -> router -> OVN gateway -> provider uplink. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 09: VM external connectivity failure | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 09 initial verification
openstack router show "${ROUTER}" -f yaml

# [EDPM][RO] INCIDENT 09 relevant logs or fault-domain state
sudo journalctl -u "${OVN_CONTROLLER_UNIT}" --since "${SINCE}" --no-pager

# [EDPM][RO] INCIDENT 09 conditional deeper boundary inspection
sudo ovs-vsctl show

# [OCP][RO] INCIDENT 10 Floating IP unreachable: transaction = external ingress -> gateway chassis -> OVN DNAT -> guest security. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 10: Floating IP unreachable | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 10 initial verification
openstack floating ip show "${FLOATING_IP_ID}" -f yaml

# [EDPM][RO] INCIDENT 10 relevant logs or fault-domain state
sudo podman logs --since 1h "${OVN_CONTROLLER_CONTAINER}"

# [OCP][RO] INCIDENT 10 conditional deeper boundary inspection
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-nat-list "${OVN_ROUTER}"

# [OCP][RO] INCIDENT 11 Volume stuck attaching: transaction = Nova attachment -> Cinder attachment -> backend -> libvirt device. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 11: Volume stuck attaching | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 11 initial verification
openstack volume show "${VOLUME}" -f yaml

# [OCP][RO] INCIDENT 11 relevant logs or fault-domain state
oc logs -n "${NS}" "${CINDER_API_POD}" --since=1h --all-containers=true

# [EDPM][RO] INCIDENT 11 conditional deeper boundary inspection
sudo multipath -ll

# [OCP][RO] INCIDENT 12 Volume stuck creating: transaction = Cinder API -> scheduler backend selection -> volume driver. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 12: Volume stuck creating | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 12 initial verification
openstack volume service list --long

# [OCP][RO] INCIDENT 12 relevant logs or fault-domain state
oc logs -n "${NS}" "${CINDER_SCHEDULER_POD}" --since=1h --all-containers=true

# [OS][RO] INCIDENT 12 conditional deeper boundary inspection
openstack volume show "${VOLUME}" -f yaml

# [OCP][RO] INCIDENT 13 Scheduler RPC failure: transaction = Nova API -> message bus -> scheduler. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 13: Scheduler RPC failure | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 13 initial verification
openstack compute service list --service nova-scheduler

# [OCP][RO] INCIDENT 13 relevant logs or fault-domain state
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" --since=1h --all-containers=true

# [OCP][RO] INCIDENT 13 conditional deeper boundary inspection
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues

# [OCP][RO] INCIDENT 14 OVN chassis missing: transaction = EDPM ovn-controller -> OVS SB connection -> chassis registration. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 14: OVN chassis missing | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 14 initial verification
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl chassis-list

# [EDPM][RO] INCIDENT 14 relevant logs or fault-domain state
sudo journalctl -u "${OVN_CONTROLLER_UNIT}" --since "${SINCE}" --no-pager

# [EDPM][RO] INCIDENT 14 conditional deeper boundary inspection
sudo ovs-vsctl get Open_vSwitch . external_ids

# [OCP][RO] INCIDENT 15 OVN gateway failure: transaction = gateway chassis -> provider bridge -> external L2/L3. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 15: OVN gateway failure | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 15 initial verification
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Port_Binding

# [EDPM][RO] INCIDENT 15 relevant logs or fault-domain state
sudo journalctl -u "${OVN_CONTROLLER_UNIT}" --since "${SINCE}" --no-pager

# [EDPM][RO] INCIDENT 15 conditional deeper boundary inspection
sudo ovs-vsctl list-br

# [OCP][RO] INCIDENT 16 Neutron API unavailable: transaction = client -> route/endpoint -> Neutron API pod -> DB/RPC. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 16: Neutron API unavailable | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 16 initial verification
openstack network list

# [OCP][RO] INCIDENT 16 relevant logs or fault-domain state
oc logs -n "${NS}" "${NEUTRON_API_POD}" --since=1h --all-containers=true

# [OCP][RO] INCIDENT 16 conditional deeper boundary inspection
oc get svc,endpointslices,routes -n "${NS}"

# [OCP][RO] INCIDENT 17 Keystone authentication failure: transaction = client -> Keystone endpoint -> identity backend. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 17: Keystone authentication failure | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 17 initial verification
openstack token issue -f value -c expires

# [OCP][RO] INCIDENT 17 relevant logs or fault-domain state
oc logs -n "${NS}" "${KEYSTONE_API_POD}" --since=1h --all-containers=true

# [OS][RO] INCIDENT 17 conditional deeper boundary inspection
openstack endpoint list --service keystone

# [OCP][RO] INCIDENT 18 RabbitMQ backlog: transaction = producer -> broker queue -> consumer acknowledgments. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 18: RabbitMQ backlog | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 18 initial verification
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues name messages_ready messages_unacknowledged consumers

# [OCP][RO] INCIDENT 18 relevant logs or fault-domain state
oc logs -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" --since=1h

# [OCP][RO] INCIDENT 18 conditional deeper boundary inspection
oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_connections

# [OCP][RO] INCIDENT 19 Galera unsynced: transaction = service DB access -> Galera node -> primary component. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 19: Galera unsynced | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 19 initial verification
oc get galera -n "${NS}"

# [OCP][RO] INCIDENT 19 relevant logs or fault-domain state
oc logs -n "${NS}" "${GALERA_POD}" -c "${GALERA_CONTAINER}" --since=1h

# [OCP][RO] INCIDENT 19 conditional deeper boundary inspection
oc get pods,pvc -n "${NS}" | grep -i galera

# [OCP][RO] INCIDENT 20 Ceph degraded: transaction = backend client I/O -> Ceph pool/PG -> OSD quorum. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 20: Ceph degraded | compare request UUID + UTC time across hops"

# [CEPH][RO] INCIDENT 20 initial verification
ceph health detail

# [CEPH][RO] INCIDENT 20 relevant logs or fault-domain state
ceph -s

# [CEPH][RO] INCIDENT 20 conditional deeper boundary inspection
ceph osd perf

# [OCP][RO] INCIDENT 21 EDPM deployment failure: transaction = NodeSet desired state -> Ansible EE Job -> EDPM host. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 21: EDPM deployment failure | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 21 initial verification
oc get openstackdataplanedeployment -n "${NS}" "${DP_DEPLOYMENT}" -o yaml

# [OCP][RO] INCIDENT 21 relevant logs or fault-domain state
oc logs -n "${NS}" job/"${ANSIBLE_JOB}" --since=2h --all-containers=true

# [OCP][RO] INCIDENT 21 conditional deeper boundary inspection
oc get jobs -n "${NS}" -l "openstackdataplanedeployment=${DP_DEPLOYMENT}"

# [OCP][RO] INCIDENT 22 Operator reconciliation failure: transaction = source OpenStackControlPlane CR -> service Operator -> generated resources. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 22: Operator reconciliation failure | compare request UUID + UTC time across hops"

# [OCP][RO] INCIDENT 22 initial verification
oc get openstackcontrolplane -n "${NS}" -o yaml

# [OCP][RO] INCIDENT 22 relevant logs or fault-domain state
oc logs -n "${OPERATORS_NS}" deployment/"${OPERATOR_DEPLOYMENT}" --since=1h --all-containers=true

# [OCP][RO] INCIDENT 22 conditional deeper boundary inspection
oc get events -n "${NS}" --sort-by=.lastTimestamp

# [OCP][RO] INCIDENT 23 API endpoint unavailable: transaction = client -> public/internal API endpoint -> router/service -> pod. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 23: API endpoint unavailable | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 23 initial verification
openstack endpoint list

# [OCP][RO] INCIDENT 23 relevant logs or fault-domain state
oc logs -n "${NS}" "${API_POD}" --since=1h --all-containers=true

# [OCP][RO] INCIDENT 23 conditional deeper boundary inspection
oc get route,svc,endpointslices -n "${NS}"

# [OCP][RO] INCIDENT 24 Insufficient compute capacity: transaction = scheduler -> Placement provider inventory/allocations -> compute host. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 24: Insufficient compute capacity | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 24 initial verification
openstack hypervisor stats show

# [OCP][RO] INCIDENT 24 relevant logs or fault-domain state
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" --since=1h --all-containers=true

# [OS][RO] INCIDENT 24 conditional deeper boundary inspection
openstack resource provider usage show "${RESOURCE_PROVIDER_UUID}"

# [OCP][RO] INCIDENT 25 Live migration failure: transaction = Nova API -> source/destination nova-compute -> libvirt -> storage/network. FIRST PROVEN FAILURE BOUNDARY is the first response/log mismatch; no RCA is preasserted.
printf "%s\n" "INCIDENT 25: Live migration failure | compare request UUID + UTC time across hops"

# [OS][RO] INCIDENT 25 initial verification
openstack server migration list --server "${VM}"

# [EDPM][RO] INCIDENT 25 relevant logs or fault-domain state
sudo journalctl -u "${NOVA_COMPUTE_UNIT}" --since "${SINCE}" --no-pager

# [OS][RO] INCIDENT 25 conditional deeper boundary inspection
openstack server migration show "${VM}" "${MIGRATION_ID}"
```