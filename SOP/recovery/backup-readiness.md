# SOP-REC-001: Control-plane backup readiness verification

| Field | Value |
| --- | --- |
| Status / version | DRAFT / 0.1.0 |
| Scope | RHOSO control-plane state, OADP/Velero when supported and deployed |
| Execution | [OCP] authenticated admin workstation |
| Owner / approver | To be assigned |
| Last site validation | Not performed |

## Purpose and release gate

**Transaction:** administrator inspects whether configured, recent backup artifacts are ready to support a **documented recovery objective**. This is a read-only readiness review, not a backup/restore execution or proof of recoverability.

The original RHOSO 18.x reference identifies version prerequisites for the OADP method (RHOSO 18.0.21+, OpenShift 4.20+, OADP 1.5+). Recheck current Red Hat support, exact RHOSO maintenance release, OpenShift/OADP versions, storage-backup method and cluster topology before approving this SOP. External Ceph, ODF, database and EDPM configuration protection may need separate procedures.

## Read-only inventory (execute only for installed APIs)

~~~bash
# [OCP][RO] Confirm cluster identity, versions and RHOSO CR namespace.
oc whoami
oc get clusterversion
oc get openstackcontrolplanes -A
oc get openstackdataplanenodesets -A
oc get openstackdataplanedeployments -A

# [OCP][RO] Detect relevant APIs; absence is UNAVAILABLE, not HEALTHY.
oc api-resources | grep -Ei 'dataprotectionapplication|backupstoragelocation|velero|volumesnapshot'

# [OCP][RO] If DataProtectionApplication CRD is installed:
oc get dataprotectionapplications.oadp.openshift.io -A

# [OCP][RO] If Velero API CRDs are installed:
oc get backupstoragelocations.velero.io -A
oc get backups.velero.io -A
oc get schedules.velero.io -A
oc get restores.velero.io -A

# [OCP][RO] If VolumeSnapshot CRD is installed:
oc get volumesnapshots.snapshot.storage.k8s.io -A
~~~

## Acceptance evidence

- RPO, RTO, backup schedule, most recent successful run, age, artifact integrity and retention are documented and approved.
- BackupStorageLocation accessibility, object-store retention, encryption, credential lifecycle and off-cluster availability have been separately verified by authorized operators.
- Database consistency and persistent volume protection are evaluated for the **actual** deployed storage drivers, databases and release.
- A restore exercise was performed in an isolated, supported test environment, or **recovery remains UNVERIFIED**. Listing a completed Backup CR is not a restore test.
- Redacted references and gaps are recorded; secrets or raw backup archives are never committed to git.

## Stop and escalation

Do not generate or run restore/delete commands as part of this SOP. If release support, storage integrity, restore isolation, backup freshness or authoritative configuration is unknown, mark **UNAVAILABLE/WARN** and escalate to the DR owner. Follow release-specific Red Hat restore documentation and a separately approved, exercised DR plan.

References: [RHOSO administration documentation](../../docs/official-sources.md) and [recovery command reference](../../docs/18-backup-disaster-recovery.md).