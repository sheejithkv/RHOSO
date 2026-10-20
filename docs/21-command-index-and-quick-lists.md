# 21. COMMAND INDEX AND OPERATIONAL QUICK LISTS

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Command index and TOP 30/20 grouped sets are generated from the sections above. Duplicate quick-list commands are deliberate cross-reference indexes, not new command syntax.


# CATEGORY: OpenShift
# [OCP][INDEX] Inspect operator readiness and degradation
# oc get clusteroperators
# [OCP][INDEX] Inspect cluster node inventory
# oc get nodes -o wide
# [OCP][INDEX] Inspect all node condition transitions
# oc get nodes -o json | jq -r '.items[] | [.metadata.name,((.status.conditions // [])|map(select(.type=="Ready"))|.[0].status),((.status.conditions // [])|map(select(.type=="Ready"))|.[0].lastTransitionTime)]|@tsv'
# [OCP][INDEX] Inspect nodes resource pressure
# oc adm top nodes
# [OCP][INDEX] Inspect node labels
# oc get nodes --show-labels
# [OCP][INDEX] Inspect node taints
# oc get nodes -o custom-columns=NODE:.metadata.name,TAINTS:.spec.taints

# CATEGORY: Control Plane
# [OCP][INDEX] Discover RHOSO control plane namespace(s)
# oc get openstackcontrolplane -A
# [OCP][INDEX] Review operator pod readiness
# oc get pods -n "${OPERATORS_NS}" -o wide
# [OCP][INDEX] Inspect control plane spec, status and conditions
# oc get openstackcontrolplane "${CONTROLPLANE_NAME}" -n "${NS}" -o yaml
# [OCP][INDEX] Read control plane readiness summary
# oc get openstackcontrolplane -n "${NS}"
# [OCP][INDEX] List control plane deployments
# oc get deployments,statefulsets,daemonsets -n "${NS}" -o wide
# [OCP][INDEX] Inspect enabled services in operator-managed source spec
# oc get openstackcontrolplane "${CONTROLPLANE_NAME}" -n "${NS}" -o json | jq '.spec|keys'

# CATEGORY: EDPM
# [OCP][INDEX] Discover NodeSets
# oc get openstackdataplanenodesets -A
# [OCP][INDEX] Discover OpenStackAnsibleEE resources
# oc get openstackansibleee -A
# [OCP][INDEX] Inspect NodeSet configuration and host inventory
# oc get openstackdataplanenodeset -n "${NS}" "${NODESET}" -o yaml
# [OCP][INDEX] Find Ansible execution resources for deployment
# oc get openstackansibleee -n "${NS}" -l "openstackdataplanedeployment=${DP_DEPLOYMENT}"
# [EDPM][INDEX] List service unit names
# systemctl list-units --type=service --all --no-pager
# [EDPM][INDEX] INCIDENT 04 conditional deeper boundary inspection
# systemctl list-units --type=service --all --no-pager

# CATEGORY: Nova
# [OS][INDEX] Discover optional service-specific command flags
# openstack server create --help
# [OS][INDEX] Read server API operations
# openstack server list --limit 1
# [OS][INDEX] List Compute service states
# openstack compute service list
# [OS][INDEX] Inspect compute service host in listing
# openstack compute service list --host "${COMPUTE_HOST}"
# [OS][INDEX] List registered hypervisors
# openstack hypervisor list
# [OS][INDEX] Inspect hypervisor resources
# openstack hypervisor show "${COMPUTE_HOST}"

# CATEGORY: Nova Cells
# [OCP][INDEX] Read nova-manage cell command help from actual image
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 --help
# [OCP][INDEX] List Nova cells (contains sensitive transport/DB connection endpoints; redact before sharing)
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_cells
# [OCP][INDEX] List host mappings by cell
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts
# [OCP][INDEX] INCIDENT 06 initial verification
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts
# [OCP][INDEX] Inspect compute cell mapping before maintenance
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts
# [OCP][INDEX] Verify Nova cell mappings from discovered conductor
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts

# CATEGORY: Placement
# [OS][INDEX] List Placement resource providers (plugin required)
# openstack resource provider list
# [OS][INDEX] Inspect resource provider
# openstack resource provider show "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List per-provider inventories
# openstack resource provider inventory list "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List provider current usage
# openstack resource provider usage show "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List resource provider traits
# openstack resource provider trait list "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List resource provider aggregates
# openstack resource provider aggregate list "${RESOURCE_PROVIDER_UUID}"

# CATEGORY: Neutron
# [OS][INDEX] Read network API operations
# openstack network list
# [OS][INDEX] List VM associated ports
# openstack port list --server "${VM}"
# [OS][INDEX] Inspect network-agent state
# openstack network agent list
# [OS][INDEX] Inspect selected agent record
# openstack network agent show "${AGENT_ID}"
# [OS][INDEX] List networks and IDs
# openstack network list --long
# [OS][INDEX] Inspect network provider segmentation, MTU and flags
# openstack network show "${NETWORK}" -f yaml

# CATEGORY: OVN
# [OCP][INDEX] Display northbound logical topology using validated RHOSO pod execution
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl show
# [OCP][INDEX] List northbound logical switches
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl ls-list
# [OCP][INDEX] List northbound logical routers
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-list
# [OCP][INDEX] List logical switch ports of chosen switch
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lsp-list "${OVN_SWITCH}"
# [OCP][INDEX] List logical router ports
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lrp-list "${OVN_ROUTER}"
# [OCP][INDEX] List logical router NAT rules
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-nat-list "${OVN_ROUTER}"

# CATEGORY: OVS
# [EDPM][INDEX] Inspect LACP/bond status where OVS bond used
# sudo ovs-appctl bond/show
# [EDPM][INDEX] Inspect OVS topology on EDPM node
# sudo ovs-vsctl show
# [EDPM][INDEX] List OVS bridges
# sudo ovs-vsctl list-br
# [EDPM][INDEX] Inspect br-int interfaces
# sudo ovs-vsctl list-ports br-int
# [EDPM][INDEX] Inspect physical provider bridge ports
# sudo ovs-vsctl list-ports "${PROVIDER_BRIDGE}"
# [EDPM][INDEX] Inspect OVS interface details
# sudo ovs-vsctl list Interface

# CATEGORY: Cinder
# [OS][INDEX] Read block storage API operations where enabled
# openstack volume list
# [OS][INDEX] List Cinder backends and enabled/down state
# openstack volume service list --long
# [OS][INDEX] List Cinder volumes including projects
# openstack volume list --all-projects --long
# [OS][INDEX] Inspect volume status and attachments
# openstack volume show "${VOLUME}" -f yaml
# [OS][INDEX] List volume types
# openstack volume type list --long
# [OS][INDEX] Inspect backend-name type mapping
# openstack volume type show "${VOLUME_TYPE}"

# CATEGORY: Glance
# [OS][INDEX] Read image API operations
# openstack image list
# [OS][INDEX] List images and visibility
# openstack image list --long
# [OS][INDEX] Inspect image formats and checksum fields
# openstack image show "${IMAGE}" -f yaml
# [OS][INDEX] Inspect image sharing membership
# openstack image member list "${IMAGE}"
# [OS][INDEX] Inspect image import feature options
# openstack image import --help
# [OS][INDEX] Inspect image API capabilities
# openstack image create --help

# CATEGORY: Keystone
# [OS][INDEX] Validate token issuance without exposing token
# openstack token issue -f value -c expires
# [OS][INDEX] List users
# openstack user list
# [OS][INDEX] Inspect user and disabled state
# openstack user show "${USER_ID}"
# [OS][INDEX] List role definitions
# openstack role list
# [OS][INDEX] Inspect effective role grants with names
# openstack role assignment list --names
# [OS][INDEX] Inspect system scoped administrative role assignments
# openstack role assignment list --names --system all

# CATEGORY: RabbitMQ
# [OCP][INDEX] Read RabbitMQ node cluster membership
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl cluster_status
# [OCP][INDEX] Read RabbitMQ node diagnostics
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmq-diagnostics status
# [OCP][INDEX] Inspect RabbitMQ node listeners
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmq-diagnostics listeners
# [OCP][INDEX] List RabbitMQ queues
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues
# [OCP][INDEX] Show per-queue depth/consumers/memory
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues name messages_ready messages_unacknowledged consumers memory
# [OCP][INDEX] List established message broker connections
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_connections

# CATEGORY: Galera
# [OCP][INDEX] Connect interactively as DBA (password prompted, not CLI/history; must be authorized)
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p
# [OCP][INDEX] Read wsrep cluster membership; interactive password prompt
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size';"
# [OCP][INDEX] Read Galera primary component status
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status';"
# [OCP][INDEX] Read local sync state
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment';"
# [OCP][INDEX] Check node readiness to accept writes
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_ready';"
# [OCP][INDEX] Read Galera replication connectivity
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_connected';"

# CATEGORY: Ceph
# [CEPH][INDEX] Inspect Ceph health and detail
# ceph -s && ceph health detail
# [CEPH][INDEX] Inspect Ceph monitor quorum
# ceph quorum_status --format json-pretty
# [CEPH][INDEX] Inspect Ceph monitors
# ceph mon dump
# [CEPH][INDEX] Inspect active manager modules
# ceph mgr dump --format json-pretty
# [CEPH][INDEX] Inspect OSD tree
# ceph osd tree
# [CEPH][INDEX] Inspect OSD counts and states
# ceph osd stat

# CATEGORY: Monitoring
# [OCP][INDEX] Discover Prometheus resources
# oc get prometheus -A
# [OCP][INDEX] Discover ServiceMonitors
# oc get servicemonitors -A
# [OCP][INDEX] Discover PrometheusRules
# oc get prometheusrules -A

# CATEGORY: Troubleshooting
# [OCP][INDEX] Review operator log errors from a selected deployment
# oc logs -n "${OPERATORS_NS}" deployment/"${OPERATOR_DEPLOYMENT}" --since=30m --all-containers=true
# [OCP][INDEX] Retrieve bounded Ansible logs for selected EE pod
# oc logs -n "${NS}" "${ANSIBLE_POD}" --all-containers=true --since=60m
# [OCP][INDEX] Inspect failed Ansible job logs via Job controller
# oc logs -n "${NS}" job/"${ANSIBLE_JOB}" --all-containers=true --since=60m
# [EDPM][INDEX] Inspect recent kernel errors
# sudo journalctl -k --since "1 hour ago" -p warning --no-pager
# [OCP][INDEX] Review Nova scheduler service log around original request ID
# oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" -c "${NOVA_SCHEDULER_CONTAINER}" --since=60m | grep -F "${REQUEST_ID}"
# [OCP][INDEX] Review conductor service log around request ID
# oc logs -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" --since=60m | grep -F "${REQUEST_ID}"

# CATEGORY: Maintenance

# CATEGORY: Backup
# [OCP][INDEX] Verify RHOSO backup configuration CR introduced in supported FR
# oc get openstackbackupconfig -n "${NS}"
# [OCP][INDEX] Inspect complete backup configuration (review secret references carefully)
# oc get openstackbackupconfig -n "${NS}" -o yaml
# [OCP][INDEX] Inventory Velero backups and phase
# oc get backups.velero.io -n openshift-adp

# TOP 30 RHOSO DAILY ADMINISTRATION COMMANDS
# [OCP][INDEX] Inspect cluster node inventory
# oc get nodes -o wide
# [OCP][INDEX] Inspect operator readiness and degradation
# oc get clusteroperators
# [OCP][INDEX] Inspect cluster version
# oc get clusterversion -o wide
# [OCP][INDEX] Inspect nodes resource pressure
# oc adm top nodes
# [OCP][INDEX] Get latest cluster events
# oc get events -A --sort-by=.lastTimestamp
# [OCP][INDEX] Get pods with node placement
# oc get pods -A -o wide
# [OCP][INDEX] List PersistentVolumeClaims
# oc get pvc -A
# [OCP][INDEX] Discover RHOSO control plane namespace(s)
# oc get openstackcontrolplane -A
# [OCP][INDEX] Discover NodeSets
# oc get openstackdataplanenodesets -A
# [OCP][INDEX] Discover deployments
# oc get openstackdataplanedeployments -A
# [OCP][INDEX] Discover OpenStackAnsibleEE resources
# oc get openstackansibleee -A
# [OCP][INDEX] List all Galera CRs and topology
# oc get galera -A
# [OCP][INDEX] List RHOSO RabbitMQ CR status
# oc get rabbitmq -A --show-labels
# [OCP][INDEX] List control plane deployments
# oc get deployments,statefulsets,daemonsets -n "${NS}" -o wide
# [OS][INDEX] Validate token issuance without exposing token
# openstack token issue -f value -c expires
# [OS][INDEX] Inspect registered services
# openstack service list
# [OS][INDEX] Inspect API endpoint registration
# openstack endpoint list
# [OS][INDEX] List Compute service states
# openstack compute service list
# [OS][INDEX] List registered hypervisors
# openstack hypervisor list
# [OS][INDEX] Inspect aggregated hypervisor capacity
# openstack hypervisor stats show
# [OS][INDEX] Inspect network-agent state
# openstack network agent list
# [OS][INDEX] Read network API operations
# openstack network list
# [OS][INDEX] List routers
# openstack router list --long
# [OS][INDEX] List VM associated ports
# openstack port list --server "${VM}"
# [OS][INDEX] List Cinder backends and enabled/down state
# openstack volume service list --long
# [OS][INDEX] Read block storage API operations where enabled
# openstack volume list
# [OS][INDEX] Read image API operations
# openstack image list
# [OCP][INDEX] List host mappings by cell
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts
# [OCP][INDEX] Display northbound logical topology using validated RHOSO pod execution
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl show
# [OCP][INDEX] List OVN registered chassis
# oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl chassis-list

# TOP 30 RHOSO TROUBLESHOOTING COMMANDS
# [OCP][INDEX] Read scoped pod events and container states
# oc describe pod -n "${NS}" "${POD}"
# [OCP][INDEX] Review operator log errors from a selected deployment
# oc logs -n "${OPERATORS_NS}" deployment/"${OPERATOR_DEPLOYMENT}" --since=30m --all-containers=true
# [OCP][INDEX] Get latest cluster events
# oc get events -A --sort-by=.lastTimestamp
# [OCP][INDEX] List EndpointSlices and owning service labels
# oc get endpointslices -A --show-labels
# [OCP][INDEX] Inspect API routes
# oc get routes -n "${NS}"
# [OCP][INDEX] List PersistentVolumeClaims
# oc get pvc -A
# [OCP][INDEX] Find deployment Ansible Kubernetes Jobs
# oc get jobs -n "${NS}" -l "openstackdataplanedeployment=${DP_DEPLOYMENT}"
# [OCP][INDEX] Discover deployments
# oc get openstackdataplanedeployments -A
# [OCP][INDEX] Discover OpenStackAnsibleEE resources
# oc get openstackansibleee -A
# [EDPM][INDEX] Inspect recent kernel errors
# sudo journalctl -k --since "1 hour ago" -p warning --no-pager
# [EDPM][INDEX] Discover failed systemd units
# sudo systemctl --failed --no-pager
# [OS][INDEX] Inspect VM state and fault message
# openstack server show "${VM}" -f yaml
# [OS][INDEX] Retrieve VM console log
# openstack console log show "${VM}"
# [OS][INDEX] List Compute service states
# openstack compute service list
# [OS][INDEX] Inspect hypervisor resources
# openstack hypervisor show "${COMPUTE_HOST}"
# [OS][INDEX] List per-provider inventories
# openstack resource provider inventory list "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List provider current usage
# openstack resource provider usage show "${RESOURCE_PROVIDER_UUID}"
# [OCP][INDEX] List Nova cells (contains sensitive transport/DB connection endpoints; redact before sharing)
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_cells
# [OCP][INDEX] List host mappings by cell
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts
# [OS][INDEX] Inspect binding details, security settings and allowed pairs
# openstack port show "${PORT_ID}" -f yaml
# [OS][INDEX] Inspect selected floating IP mapping
# openstack floating ip show "${FLOATING_IP_ID}" -f yaml
# [OCP][INDEX] Display northbound logical topology using validated RHOSO pod execution
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl show
# [OCP][INDEX] List logical router NAT rules
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-nat-list "${OVN_ROUTER}"
# [OCP][INDEX] Inspect southbound port bindings
# oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Port_Binding
# [OCP][INDEX] List OVN registered chassis
# oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl chassis-list
# [EDPM][INDEX] Inspect OVS topology on EDPM node
# sudo ovs-vsctl show
# [OCP][INDEX] List RabbitMQ queues
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl list_queues
# [OCP][INDEX] Read RabbitMQ node cluster membership
# oc exec -n "${NS}" "${RABBIT_POD}" -c "${RABBIT_CONTAINER}" -- rabbitmqctl cluster_status
# [OCP][INDEX] Read wsrep cluster membership; interactive password prompt
# oc rsh -n "${NS}" -c "${GALERA_CONTAINER}" "${GALERA_POD}" mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size';"
# [CEPH][INDEX] Inspect Ceph health and detail
# ceph -s && ceph health detail

# TOP 20 RHOSO NETWORK TROUBLESHOOTING COMMANDS
# [OS][INDEX] Inspect network-agent state
# openstack network agent list
# [OS][INDEX] Inspect network provider segmentation, MTU and flags
# openstack network show "${NETWORK}" -f yaml
# [OS][INDEX] Inspect subnet DHCP, DNS and routes
# openstack subnet show "${SUBNET}" -f yaml
# [OS][INDEX] Inspect router gateway and attached ports
# openstack router show "${ROUTER}" -f yaml
# [OS][INDEX] Inspect binding details, security settings and allowed pairs
# openstack port show "${PORT_ID}" -f yaml
# [OS][INDEX] Inspect selected floating IP mapping
# openstack floating ip show "${FLOATING_IP_ID}" -f yaml
# [OS][INDEX] List individual security group rules
# openstack security group rule list "${SECURITY_GROUP}"
# [OS][INDEX] Inspect network QoS policies
# openstack network qos policy list
# [OCP][INDEX] Display northbound logical topology using validated RHOSO pod execution
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl show
# [OCP][INDEX] List northbound logical switches
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl ls-list
# [OCP][INDEX] List northbound logical routers
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-list
# [OCP][INDEX] List logical router NAT rules
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl lr-nat-list "${OVN_ROUTER}"
# [OCP][INDEX] Inspect OVN DHCP option rows
# oc exec -n "${NS}" "${OVN_NB_POD}" -c "${OVN_NB_CONTAINER}" -- ovn-nbctl list DHCP_Options
# [OCP][INDEX] Show southbound topology
# oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl show
# [OCP][INDEX] List OVN registered chassis
# oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl chassis-list
# [OCP][INDEX] Inspect southbound port bindings
# oc exec -n "${NS}" "${OVN_SB_POD}" -c "${OVN_SB_CONTAINER}" -- ovn-sbctl list Port_Binding
# [EDPM][INDEX] Inspect OVS topology on EDPM node
# sudo ovs-vsctl show
# [EDPM][INDEX] List OVS bridges
# sudo ovs-vsctl list-br
# [EDPM][INDEX] Inspect br-int OpenFlow pipeline (can be large)
# sudo ovs-ofctl -O OpenFlow13 dump-flows br-int
# [EDPM][INDEX] Inspect routes and selected next-hop
# ip route show table all

# TOP 20 RHOSO COMPUTE TROUBLESHOOTING COMMANDS
# [OS][INDEX] List Compute service states
# openstack compute service list
# [OS][INDEX] List registered hypervisors
# openstack hypervisor list
# [OS][INDEX] Inspect hypervisor resources
# openstack hypervisor show "${COMPUTE_HOST}"
# [OS][INDEX] Inspect aggregated hypervisor capacity
# openstack hypervisor stats show
# [OCP][INDEX] List Nova cells (contains sensitive transport/DB connection endpoints; redact before sharing)
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_cells
# [OCP][INDEX] List host mappings by cell
# oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts
# [OS][INDEX] List Placement resource providers (plugin required)
# openstack resource provider list
# [OS][INDEX] List per-provider inventories
# openstack resource provider inventory list "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List provider current usage
# openstack resource provider usage show "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] List resource provider traits
# openstack resource provider trait list "${RESOURCE_PROVIDER_UUID}"
# [OS][INDEX] Inspect VM state and fault message
# openstack server show "${VM}" -f yaml
# [OS][INDEX] List VMs resident on compute host
# openstack server list --all-projects --host "${COMPUTE_HOST}"
# [OS][INDEX] List live and cold migration records
# openstack server migration list --server "${VM}"
# [OS][INDEX] Retrieve VM console log
# openstack console log show "${VM}"
# [OS][INDEX] Inspect host aggregate members and properties
# openstack aggregate show "${AGGREGATE}"
# [OS][INDEX] Inspect affinity/anti-affinity policy
# openstack server group show "${SERVER_GROUP}"
# [OS][INDEX] Inspect selected flavor extra specs
# openstack flavor show "${FLAVOR}"
# [EDPM][INDEX] Inspect CPU NUMA node summary
# numactl --hardware
# [EDPM][INDEX] Inspect hugepages and memory
# grep -Ei "HugePages|Hugepagesize|MemTotal|MemAvailable" /proc/meminfo
# [EDPM][INDEX] EDPM Nova Compute service logs
# sudo journalctl -u "${NOVA_COMPUTE_UNIT}" --since "${SINCE}" --until "${UNTIL}" --no-pager

# TOP 20 RHOSO STORAGE TROUBLESHOOTING COMMANDS
# [OS][INDEX] List Cinder backends and enabled/down state
# openstack volume service list --long
# [OS][INDEX] Read block storage API operations where enabled
# openstack volume list
# [OS][INDEX] Inspect volume status and attachments
# openstack volume show "${VOLUME}" -f yaml
# [OS][INDEX] Inspect backend-name type mapping
# openstack volume type show "${VOLUME_TYPE}"
# [OS][INDEX] List volume snapshots
# openstack volume snapshot list --all-projects
# [OS][INDEX] List volume backups
# openstack volume backup list --all-projects
# [OS][INDEX] List attached volumes
# openstack server volume list "${VM}"
# [EDPM][INDEX] Inspect multipath maps (iSCSI/FC only)
# sudo multipath -ll
# [EDPM][INDEX] Inspect iSCSI sessions, if using iSCSI
# sudo iscsiadm -m session
# [CEPH][INDEX] Inspect Ceph health and detail
# ceph -s && ceph health detail
# [CEPH][INDEX] Inspect detailed Ceph warning/error messages
# ceph health detail
# [CEPH][INDEX] Inspect OSD tree
# ceph osd tree
# [CEPH][INDEX] Inspect per-OSD usage
# ceph osd df tree
# [CEPH][INDEX] Inspect OSD performance latency
# ceph osd perf
# [CEPH][INDEX] Inspect placement-group status
# ceph pg stat
# [CEPH][INDEX] Inspect pool-level utilization
# ceph df detail
# [CEPH][INDEX] List pools with details
# ceph osd pool ls detail
# [CEPH][INDEX] Inspect RBD image metadata
# rbd info "${POOL}/${RBD_IMAGE}"
# [CEPH][INDEX] Inspect in-use client watchers
# rbd status "${POOL}/${RBD_IMAGE}"
# [OCP][INDEX] List PersistentVolumeClaims
# oc get pvc -A

# Official references: see docs/official-sources.md; executable check: scripts/rhoso-healthcheck.sh.
```