# 05. NOVA COMPUTE, CELLS AND PLACEMENT

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# nova-manage commands execute inside a discovered Nova conductor container (not OpenStackClient). [CHANGE] discover_hosts writes cell host mappings; list_cells/list_hosts are read-only. In multi-cell topologies identify intended conductor/cell using CR configuration. Never expose list_cells output in tickets without redacting DB/transport URLs.

# [OS][RO] List Compute service states
openstack compute service list

# [OS][RO] Inspect compute service host in listing
openstack compute service list --host "${COMPUTE_HOST}"

# [OS][RO] List registered hypervisors
openstack hypervisor list

# [OS][RO] Inspect hypervisor resources
openstack hypervisor show "${COMPUTE_HOST}"

# [OS][RO] Inspect aggregated hypervisor capacity
openstack hypervisor stats show

# [OS][RO] List host aggregates
openstack aggregate list

# [OS][RO] Inspect host aggregate members and properties
openstack aggregate show "${AGGREGATE}"

# [OS][RO] List availability zones
openstack availability zone list --compute

# [OS][RO] List server groups
openstack server group list

# [OS][RO] Inspect affinity/anti-affinity policy
openstack server group show "${SERVER_GROUP}"

# [OS][CHANGE] Create anti-affinity server group (change; verify scheduler policy and group quotas first)
openstack server group create --policy anti-affinity "${SERVER_GROUP}"

# [OS][RO] List all instance projects
openstack server list --all-projects --long

# [OS][RO] List VMs resident on compute host
openstack server list --all-projects --host "${COMPUTE_HOST}"

# [OS][RO] Inspect VM state and fault message
openstack server show "${VM}" -f yaml

# [OS][RO] Retrieve VM console log
openstack console log show "${VM}"

# [OS][RO] List VM associated ports
openstack port list --server "${VM}"

# [OS][RO] List attached volumes
openstack server volume list "${VM}"

# [OS][RO] List live and cold migration records
openstack server migration list --server "${VM}"

# [OS][RO] Inspect migration status
openstack server migration show "${VM}" "${MIGRATION_ID}"

# [OS][RO] Check available resize flavors
openstack flavor list --long

# [OS][RO] Inspect selected flavor extra specs
openstack flavor show "${FLAVOR}"

# [OS][RO] List project compute quotas
openstack quota show --compute "${PROJECT_ID}"

# [OS][RO] Inspect limit of VM aggregates and project usages
openstack limits show --absolute

# [OCP][RO] Discover Nova conductor pods in RHOSO namespace
oc get pods -n "${NS}" -o wide | grep -E "nova.*conductor"

# [OCP][RO] Discover container names of chosen conductor pod
oc get pod -n "${NS}" "${NOVA_CONDUCTOR_POD}" -o 'jsonpath={.spec.containers[*].name}{"\n"}'

# [OCP][RO] Read nova-manage cell command help from actual image
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 --help

# [OCP][RO] List Nova cells (contains sensitive transport/DB connection endpoints; redact before sharing)
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_cells

# [OCP][RO] List host mappings by cell
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts

# [OCP][CHANGE] Discover cell hosts after approved new compute registration (writes mappings; NOT health-check safe)
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 discover_hosts --verbose

# [OCP][RO] Inspect Nova version from selected conductor image
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage version

# [OS][RO] List Placement resource providers (plugin required)
openstack resource provider list

# [OS][RO] Inspect resource provider
openstack resource provider show "${RESOURCE_PROVIDER_UUID}"

# [OS][RO] List per-provider inventories
openstack resource provider inventory list "${RESOURCE_PROVIDER_UUID}"

# [OS][RO] List provider current usage
openstack resource provider usage show "${RESOURCE_PROVIDER_UUID}"

# [OS][RO] List resource provider traits
openstack resource provider trait list "${RESOURCE_PROVIDER_UUID}"

# [OS][RO] List resource provider aggregates
openstack resource provider aggregate list "${RESOURCE_PROVIDER_UUID}"

# [OS][RO] List Placement allocations of consumer
openstack resource provider allocation show "${VM_UUID}"

# [OS][RO] Inspect server group anti-affinity topology
openstack server group show "${SERVER_GROUP}"

# [EDPM][RO] Inspect PCI devices from selected host
lspci -nnk

# [EDPM][RO] Inspect NUMA topology and memory affinity
numastat -m

# [EDPM][RO] Inspect libvirt domain XML if authorized and VM hosted here
sudo virsh dumpxml "${LIBVIRT_DOMAIN}"

# [OCP][RO] Review Nova scheduler service log around original request ID
oc logs -n "${NS}" "${NOVA_SCHEDULER_POD}" -c "${NOVA_SCHEDULER_CONTAINER}" --since=60m | grep -F "${REQUEST_ID}"

# [OCP][RO] Review conductor service log around request ID
oc logs -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" --since=60m | grep -F "${REQUEST_ID}"

# [OS][CHANGE] Resize VM after planning capacity and guest compatibility
openstack server resize --flavor "${NEW_FLAVOR}" "${VM}"

# [OS][CHANGE] Soft reboot guest after workload owner consent
openstack server reboot --soft "${VM}"

# [OS][CHANGE] Hard reboot ONLY with workload and data integrity approval
openstack server reboot --hard "${VM}"

# [OS][CHANGE] Shelve VM after checking snapshot/capacity impact
openstack server shelve "${VM}"

# [OS][CHANGE] Unshelve VM after verifying placement capacity
openstack server unshelve "${VM}"

# [OS][CHANGE] Start stopped instance
openstack server start "${VM}"

# [OS][CHANGE] Stop instance after planned downtime notification
openstack server stop "${VM}"

# [OS][CHANGE] Create purpose-built test flavor
openstack flavor create --vcpus "${VCPU_COUNT}" --ram "${RAM_MIB}" --disk "${DISK_GIB}" "${FLAVOR}"

# [OS][CHANGE] Set approved flavor extra spec; coordinate scheduler, NUMA or PCI policy
openstack flavor set --property "${FLAVOR_EXTRA_KEY}=${FLAVOR_EXTRA_VALUE}" "${FLAVOR}"

# [OS][RO] Inspect quota update arguments before authorized adjustment
openstack quota set --help

# [OS][CHANGE] Create project host aggregate only after tenancy/AZ design review
openstack aggregate create "${AGGREGATE}"

# [OS][CHANGE] Add hypervisor host to aggregate after scheduler compatibility review
openstack aggregate add host "${AGGREGATE}" "${COMPUTE_HOST}"
```