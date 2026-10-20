# 17. COMPUTE MAINTENANCE AND CHANGE CONTROL

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Preconditions: approved change; workload owner coordination; inspect destination Placement capacity, same cell/aggregate/AZ, CPU model, hugepages, PCI/SR-IOV and shared storage live-migration support. Quiesce workloads that cannot migrate. Operator owns EDPM state; never modify generated configuration directly. Evacuation only when source host is confirmed failed/down.

# [OS][RO] Identify original compute VM workload
openstack server list --all-projects --host "${COMPUTE_HOST}"

# [OS][RO] Validate spare compute capacity before host changes
openstack hypervisor stats show

# [OS][RO] Validate scheduler and compute service health
openstack compute service list

# [OS][RO] Validate destination resource provider inventories
openstack resource provider inventory list "${DESTINATION_RP_UUID}"

# [OS][RO] Validate destination resource provider traits
openstack resource provider trait list "${DESTINATION_RP_UUID}"

# [OS][RO] Validate VM attached volumes/migration constraints
openstack server volume list "${VM}"

# [OS][RO] Inspect active migrations before drain
openstack server migration list --server "${VM}"

# [OCP][RO] Inspect compute cell mapping before maintenance
oc exec -n "${NS}" "${NOVA_CONDUCTOR_POD}" -c "${NOVA_CONDUCTOR_CONTAINER}" -- nova-manage cell_v2 list_hosts

# [OS][CHANGE] Disable scheduling on host; change impact: no NEW placements; rollback: enable; does not move guests
openstack compute service set --disable --disable-reason "${CHANGE_ID}" "${COMPUTE_HOST}" nova-compute

# [OS][RO] Validate scheduling disabled
openstack compute service list --host "${COMPUTE_HOST}"

# [OS][CHANGE] Initiate live migration of eligible VM; risk: workload blip/failure; rollback depends on migration state
openstack --os-compute-api-version 2.30 server migrate --live-migration --host "${DESTINATION_HOST}" "${VM}"

# [OS][RO] Inspect server migration state and destination
openstack server migration list --server "${VM}"

# [OS][CHANGE] Cold migrate only after allowed downtime; impact: guest outage
openstack server migrate "${VM}"

# [OS][CHANGE] Confirm cold migration after guest validation; releases previous instance placement
openstack server migration confirm "${VM}"

# [OS][CHANGE] Revert unconfirmed cold migration after documented validation failure
openstack server migration revert "${VM}"

# [OS][CHANGE] Evacuate only after fencing/confirming source host DOWN; risk: split brain without fencing
openstack server evacuate --host "${DESTINATION_HOST}" "${VM}"

# [OS][CHANGE] Re-enable scheduling after original transaction and hypervisor validation
openstack compute service set --enable "${COMPUTE_HOST}" nova-compute

# [OS][RO] Validate enabled/up after maintenance
openstack compute service list --host "${COMPUTE_HOST}"

# [OS][RO] Validate host inventory and online hypervisor
openstack hypervisor show "${COMPUTE_HOST}"

# [EDPM][RO] Inspect reboot prerequisites (storage/multipath/active libvirt domains)
sudo virsh list --all && sudo multipath -ll

# [EDPM][RO] Inspect EDPM services after approved maintenance
sudo systemctl --failed --no-pager

# [OCP][RO] Inspect OpenStackDataPlaneNodeSet desired state for replacement
oc get openstackdataplanenodeset "${NODESET}" -n "${NS}" -o yaml

# [OS][RO] Validate original VM transaction after maintenance
openstack server show "${VM}" -c status -c addresses -c OS-EXT-SRV-ATTR:host
```