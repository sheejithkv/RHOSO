# 07. OVN NORTHBOUND, SOUTHBOUND AND OPEN VSWITCH

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# RHOSO 18.0 migration documentation confirms oc exec ovsdbserver-nb-0 -- ovn-nbctl show and ovsdbserver-sb-0 -- ovn-sbctl list Chassis, but names are topology-dependent. Discover matching NB/SB pods first. Some tools may need --db URL/TLS; do not assume local socket. OVN inspection is operational debugging; do not mutate NB/SB DB outside Neutron/operator reconciliation.

# [OCP][RO] Discover OVN CRs and control plane resources
oc api-resources --verbs=list | grep -Ei "ovn|ovsdb"

# [OCP][RO] Discover OVN control plane pods
oc get pods -n "${NS}" -o wide | grep -Ei "ovsdb|ovn-northd|ovn-controller"

# [OCP][RO] Inspect all container names for selected NB database pod
oc get pod -n "${NS}" "${OVN_NB_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# [OCP][RO] Inspect all container names for selected SB database pod
oc get pod -n "${NS}" "${OVN_SB_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# [OCP][RO] Display northbound logical topology using validated RHOSO pod execution
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl show

# [OCP][RO] List northbound logical switches
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl ls-list

# [OCP][RO] List northbound logical routers
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-list

# [OCP][RO] List logical switch ports of chosen switch
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lsp-list "${OVN_SWITCH}"

# [OCP][RO] List logical router ports
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lrp-list "${OVN_ROUTER}"

# [OCP][RO] List logical router NAT rules
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-nat-list "${OVN_ROUTER}"

# [OCP][RO] List logical switch ACLs
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl acl-list "${OVN_SWITCH}"

# [OCP][RO] List northbound load balancers
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lb-list

# [OCP][RO] Inspect OVN DHCP option rows
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl list DHCP_Options

# [OCP][RO] Inspect northbound HA chassis groups
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl list HA_Chassis_Group

# [OCP][UNVERIFIED] Inspect NB database leader and cluster status via schema-specific local OVSDB; locally verify socket first
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovsdb-client list-dbs

# [OCP][RO] Show southbound topology
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl show

# [OCP][RO] List OVN registered chassis
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl chassis-list

# [OCP][RO] Inspect southbound chassis and encapsulation information
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Chassis

# [OCP][RO] Inspect chassis-private heartbeat metadata
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Chassis_Private

# [OCP][RO] Inspect southbound port bindings
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Port_Binding

# [OCP][RO] Inspect specific port binding by logical port name
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl --columns=logical_port,chassis,datapath,up find Port_Binding logical_port="${OVN_LOGICAL_PORT}"

# [OCP][RO] Inspect southbound datapath bindings
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Datapath_Binding

# [OCP][RO] Inspect logical southbound flow table by logical datapath
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl lflow-list "${OVN_DATAPATH}"

# [OCP][RO] Inspect northd service logs and sync errors
oc logs -n "${NS}" "${OVN_NORTHD_POD}" --since=30m --all-containers=true

# [EDPM][RO] Inspect selected OVN controller service logs
sudo journalctl -u "${OVN_CONTROLLER_UNIT}" --since "1 hour ago" --no-pager

# [EDPM][RO] Inspect running OVN controller container logs if containerized
sudo podman logs --since 30m "${OVN_CONTROLLER_CONTAINER}"

# [EDPM][RO] Inspect OVS topology on EDPM node
sudo ovs-vsctl show

# [EDPM][RO] List OVS bridges
sudo ovs-vsctl list-br

# [EDPM][RO] Inspect br-int interfaces
sudo ovs-vsctl list-ports br-int

# [EDPM][RO] Inspect physical provider bridge ports
sudo ovs-vsctl list-ports "${PROVIDER_BRIDGE}"

# [EDPM][RO] Inspect OVS interface details
sudo ovs-vsctl list Interface

# [EDPM][RO] Inspect external IDs including encap address and mappings (potentially internal metadata)
sudo ovs-vsctl get Open_vSwitch . external_ids

# [EDPM][RO] Inspect OVS database manager status
sudo ovs-vsctl list Open_vSwitch

# [EDPM][RO] Inspect br-int OpenFlow pipeline (can be large)
sudo ovs-ofctl -O OpenFlow13 dump-flows br-int

# [EDPM][RO] Inspect OpenFlow 13 table stats
sudo ovs-ofctl -O OpenFlow13 dump-tables br-int

# [EDPM][RO] Read OVN controller connection status (local control socket required)
sudo ovn-appctl -t ovn-controller connection-status

# [EDPM][RO] Show OVN runtime logical-to-physical flows (local control socket required)
sudo ovn-appctl -t ovn-controller lflow-list

# [OCP][RO] Display ovn-trace supported syntax from actual NB tool image
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-trace --help

# [OCP][UNVERIFIED] Trace a packet through logical switch; match expression must describe actual ingress packet; verify tool path
oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-trace "${OVN_SWITCH}" "${OVN_TRACE_FLOW}"

# [EDPM][RO] Trace OVS physical packet; requires exact in_port and real packet header values, capture only
sudo ovs-appctl ofproto/trace br-int "${OVS_TRACE_FLOW}"

# [OCP][RO] Inspect OVN SB DB schema
oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl --help
```