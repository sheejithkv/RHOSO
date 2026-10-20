# 08. CINDER BLOCK STORAGE ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# State-changing volume migration, retype, encryption and backups require storage driver capability and data-protection review. [OS] Cinder API; [EDPM] attach path and multipath; [CEPH] RBD backend.

# [OS][RO] List Cinder backends and enabled/down state
openstack volume service list --long

# [OS][RO] List Cinder volumes including projects
openstack volume list --all-projects --long

# [OS][RO] Inspect volume status and attachments
openstack volume show "${VOLUME}" -f yaml

# [OS][RO] List volume types
openstack volume type list --long

# [OS][RO] Inspect backend-name type mapping
openstack volume type show "${VOLUME_TYPE}"

# [OS][RO] List volume snapshots
openstack volume snapshot list --all-projects

# [OS][RO] Inspect snapshot
openstack volume snapshot show "${SNAPSHOT}"

# [OS][RO] List volume backups
openstack volume backup list --all-projects

# [OS][RO] Inspect volume backup
openstack volume backup show "${BACKUP}"

# [OS][RO] Inspect volume project quota
openstack quota show --volume "${PROJECT_ID}"

# [OS][UNVERIFIED] List volume migrations and metadata from show
openstack volume show "${VOLUME}" -c migration_status -c os-vol-mig-status-attr:migstat

# [OS][RO] Inspect volume encryption type for selected type
openstack volume type show "${VOLUME_TYPE}" -f yaml

# [EDPM][RO] Inspect multipath maps (iSCSI/FC only)
sudo multipath -ll

# [EDPM][RO] Inspect iSCSI sessions, if using iSCSI
sudo iscsiadm -m session

# [EDPM][RO] Check relevant kernel storage errors
sudo journalctl -k --since "1 hour ago" --no-pager | grep -Ei "iscsi|multipath|rbd|blk|nvme|scsi"

# [OCP][RO] Discover Cinder controller pods
oc get pods -n "${NS}" | grep -i cinder

# [OCP][RO] Read selected Cinder scheduler logs
oc logs -n "${NS}" "${CINDER_SCHEDULER_POD}" --since=30m --all-containers=true

# [OCP][RO] Read selected Cinder volume logs (may run in control plane or external backend role)
oc logs -n "${NS}" "${CINDER_VOLUME_POD}" --since=30m --all-containers=true

# [OS][CHANGE] Create volume with approved backend volume type
openstack volume create --size "${VOLUME_SIZE_GIB}" --type "${VOLUME_TYPE}" "${VOLUME_NAME}"

# [OS][CHANGE] Create volume snapshot after app-consistency considerations
openstack volume snapshot create --volume "${VOLUME}" "${SNAPSHOT}"

# [OS][CHANGE] Create volume backup if backup service enabled
openstack volume backup create --name "${BACKUP_NAME}" "${VOLUME}"

# [OS][CHANGE] Extend detached or safely online-expandable volume (no shrink)
openstack volume set --size "${NEW_VOLUME_SIZE_GIB}" "${VOLUME}"

# [OS][CHANGE] Retype volume after capability/impact review
openstack volume set --type "${NEW_VOLUME_TYPE}" --retype-policy on-demand "${VOLUME}"

# [OS][CHANGE] Attach approved volume to instance
openstack server add volume "${VM}" "${VOLUME}"

# [OS][CHANGE] Detach after workload/file system coordination
openstack server remove volume "${VM}" "${VOLUME}"

# [OS][RO] Inspect Cinder migration command supported flags before planned backend move
openstack volume migrate --help

# [OS][UNVERIFIED] Inspect volume type encryption settings if encryption plugin installed
openstack volume type encryption show "${VOLUME_TYPE}"

# [OCP][RO] Inspect Glance/Cinder configured storage backend resources from operator CR
oc get openstackcontrolplane "${CONTROLPLANE_NAME}" -n "${NS}" -o json | jq ".spec | {glance,cinder,nova}"
```