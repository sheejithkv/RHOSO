# 18. BACKUP, RESTORE AND DISASTER RECOVERY

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Red Hat documented RHOSO control plane OADP/Velero backup/restore requires RHOSO >=18.0.21 FR6, OpenShift >=4.20, OADP >=1.5 and Velero >=1.16. Earlier patch levels: do NOT apply this workflow. Control plane, PVC data, secrets, OVN DB, MariaDB, data-plane CRs, Ceph and external state have distinct consistency and recovery needs. Restore execution intentionally excluded.

# [OCP][RO] Confirm cluster version prerequisite
oc get clusterversion

# [OCP][RO] Inspect deployed RHOSO Operator CSV version
oc get csv -n "${OPERATORS_NS}"

# [OCP][RO] Verify OADP operator and Velero CRDs
oc get crd backups.velero.io restores.velero.io backupstoragelocations.velero.io

# [OCP][RO] Verify RHOSO backup configuration CR introduced in supported FR
oc get openstackbackupconfig -n "${NS}"

# [OCP][RO] Inspect complete backup configuration (review secret references carefully)
oc get openstackbackupconfig -n "${NS}" -o yaml

# [OCP][RO] Inspect BackupStorageLocation availability
oc get backupstoragelocation -n openshift-adp

# [OCP][RO] Inspect OADP DataProtectionApplication
oc get dataprotectionapplication -n openshift-adp

# [OCP][RO] Inspect backup schedules
oc get schedules.velero.io -n openshift-adp

# [OCP][RO] Inventory Velero backups and phase
oc get backups.velero.io -n openshift-adp

# [OCP][RO] Inspect selected backup status and errors
oc describe backup.velero.io -n openshift-adp "${BACKUP_CR}"

# [OCP][RO] Inspect ongoing and completed restore resources; does not invoke restore
oc get restores.velero.io -n openshift-adp

# [OCP][RO] Inspect selected restore metadata and phase
oc describe restore.velero.io -n openshift-adp "${RESTORE_CR}"

# [OCP][RO] Check Velero version from discovered pod; do not assume fixed pod name
oc get pods -n openshift-adp -l deploy=velero -o wide

# [OCP][RO] Run Velero version inside selected Velero pod
oc exec -n openshift-adp "${VELERO_POD}" -- /velero version

# [OCP][RO] Inspect snapshot classes with Velero label
oc get volumesnapshotclass -l velero.io/csi-volumesnapshot-class=true

# [OCP][RO] List CSI snapshots
oc get volumesnapshots.snapshot.storage.k8s.io -A

# [OCP][RO] List CSI snapshot contents
oc get volumesnapshotcontents.snapshot.storage.k8s.io

# [OCP][RO] Inspect backup namespace PVCs
oc get pvc -n "${NS}" -o wide

# [OCP][RO] Inspect Velero logs for backup failures
oc logs -n openshift-adp "${VELERO_POD}" --since=2h

# [OCP][RO] Inspect database backup-related jobs (if deployed)
oc get jobs,cronjobs -n "${NS}" | grep -Ei "backup|maria|galera"

# [OCP][RO] Inspect current OpenStack CR definitions for configuration backup
oc get openstackcontrolplane,openstackdataplanenodeset,openstackdataplanedeployment -n "${NS}" -o yaml

# [OCP][CHANGE] Export control plane CR with workstation-protected file; data may include sensitive references
oc get openstackcontrolplane -n "${NS}" -o yaml > "${PROTECTED_BACKUP_DIR}/controlplane.yaml"

# [OCP][CHANGE] Export data plane NodeSets with workstation-protected file
oc get openstackdataplanenodeset -n "${NS}" -o yaml > "${PROTECTED_BACKUP_DIR}/edpm-nodesets.yaml"

# [OCP][RO] Inspect cluster storage classes for recovery preflight
oc get storageclass -o wide

# [OCP][RO] Inspect target cluster NADs and MetalLB dependencies before any restore
oc get network-attachment-definition -A && oc get ipaddresspools.metallb.io -A
```