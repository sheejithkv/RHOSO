# 09. CEPH STORAGE ADMINISTRATION

> **Operational reference — not an executable script.** Commands and placeholders require review against your deployment. Entries tagged `[CHANGE]` or `[DELETE]` change infrastructure state. Entries tagged `[UNVERIFIED]` require local validation.

```bash
# Run only in the actual Red Hat Ceph Storage or external Ceph admin environment with corresponding credentials; for ODF/Rook discover namespace/toolbox via its supported tooling. Ceph CLI is NOT assumed inside OpenStackClient. Do not edit RBD locks or OSD state from this reference.

# [CEPH][RO] Inspect Ceph health and detail
ceph -s && ceph health detail

# [CEPH][RO] Inspect Ceph monitor quorum
ceph quorum_status --format json-pretty

# [CEPH][RO] Inspect Ceph monitors
ceph mon dump

# [CEPH][RO] Inspect active manager modules
ceph mgr dump --format json-pretty

# [CEPH][RO] Inspect OSD tree
ceph osd tree

# [CEPH][RO] Inspect OSD counts and states
ceph osd stat

# [CEPH][RO] Inspect per-OSD usage
ceph osd df tree

# [CEPH][RO] Inspect OSD performance latency
ceph osd perf

# [CEPH][RO] Inspect placement-group status
ceph pg stat

# [CEPH][RO] Inspect degraded PGs in health detail
ceph health detail

# [CEPH][RO] Inspect pool-level utilization
ceph df detail

# [CEPH][RO] List pools with details
ceph osd pool ls detail

# [CEPH][RO] Review CRUSH hierarchy
ceph osd crush tree

# [CEPH][RO] Inspect CRUSH rules
ceph osd crush rule ls

# [CEPH][RO] Inspect Ceph network addresses
ceph mon dump

# [CEPH][RO] Inspect total and free capacity
ceph df

# [CEPH][RO] Inspect recovery and misplaced objects
ceph -s

# [CEPH][RO] List Ceph orchestrator services if cephadm is deployed
ceph orch ls

# [CEPH][RO] List daemons if cephadm is deployed
ceph orch ps

# [CEPH][RO] List RBD images within approved Glance pool
rbd ls -p "${GLANCE_POOL}"

# [CEPH][RO] List RBD images within approved Cinder pool
rbd ls -p "${CINDER_POOL}"

# [CEPH][RO] List RBD images within approved Nova ephemeral pool
rbd ls -p "${NOVA_POOL}"

# [CEPH][RO] Inspect RBD image metadata
rbd info "${POOL}/${RBD_IMAGE}"

# [CEPH][RO] Inspect image snapshot metadata
rbd snap ls "${POOL}/${RBD_IMAGE}"

# [CEPH][RO] Inspect active RBD locks
rbd lock list "${POOL}/${RBD_IMAGE}"

# [CEPH][RO] Inspect in-use client watchers
rbd status "${POOL}/${RBD_IMAGE}"

# [CEPH][RO] Inspect Ceph client identities without dumping key material
ceph auth ls | grep -E "^(client|osd|mgr|mon)"

# [OCP][RO] Discover ODF CephCluster namespace where present
oc get cephclusters.ceph.rook.io -A

# [OCP][RO] Inspect ODF CephCluster status (where installed)
oc get cephclusters.ceph.rook.io -A -o wide

# [OCP][RO] Discover ODF storage cluster resources
oc get storageclusters.ocs.openshift.io -A

# [CEPH][RO] Inspect exact ceph rbd pool assigned to services in authoritative deployment configuration
ceph osd pool ls

# [OCP][RO] Discover ODF topology and Ceph pod inventory, when using ODF
oc get pods -A | grep -Ei "rook-ceph|ocs"
```