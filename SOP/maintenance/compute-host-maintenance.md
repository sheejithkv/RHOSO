# SOP-MNT-001: Scheduled RHOSO compute host maintenance

| Field | Value |
| --- | --- |
| Status / version | DRAFT / 0.1.0 |
| Scope | RHOSO 18.x EDPM compute nodes; Nova service and running instances |
| Execution | [OS] authenticated OpenStackClient; [OCP] operator/CR inventory; [EDPM] approved host |
| Owner / approver | To be assigned |
| Last site validation | Not performed |
| Official reference | https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html-single/maintaining_the_red_hat_openstack_services_on_openshift_deployment/index |

## Change gate and preconditions

Use only with an **approved** change ID, defined workload downtime tolerance, workload-owner authorization and a recovery window. Check supported release-specific host-maintenance steps, RHOSO Operator/EDPM NodeSet ownership and GitOps reconciliation before editing any desired state. Coordinate with Instance HA, if installed, to avoid false evacuation.

Confirm destination host eligibility, capacity, same Nova cell and policy/AZ/aggregate constraints, CPU model, NUMA/hugepages, PCI/SR-IOV, storage/shared-storage or block-migration support, and in-flight migrations. Do **not** assume all VMs support live migration. Do not use the word *reserved* in disable reasons when Instance HA is in use.

~~~bash
# [OCP][RO] Discover controller-owned data plane; no changes.
oc get openstackdataplanenodesets -A
oc get openstackdataplanedeployments -A

# [OS][RO] Supply real values only after reviewing the maintenance ticket.
# COMPUTE_HOST and CHANGE_ID must be set in this OpenStackClient shell.
openstack compute service list --host "$COMPUTE_HOST"
openstack server list --all-projects --host "$COMPUTE_HOST"
openstack hypervisor stats show
openstack hypervisor show "$COMPUTE_HOST"
openstack server migration list --server "$VM_UUID"
openstack server volume list "$VM_UUID"
~~~

**STOP** if host identification, source-of-truth, workload list, destination or rollback is uncertain. Host-level spare capacity is not sufficient by itself to prove Placement placement compatibility.

## Approved minimum change — operator run individually

~~~bash
# [OS][CHANGE] Disable new scheduling; existing guests are NOT moved.
openstack compute service set --disable --disable-reason "$CHANGE_ID" "$COMPUTE_HOST" nova-compute

# [OS][RO] Verify host scheduling state and unaffected VM inventory.
openstack compute service list --host "$COMPUTE_HOST"
openstack server list --all-projects --host "$COMPUTE_HOST"

# [OS][CHANGE] Optional; only for a VM confirmed live-migration compatible.
# Requires an approved target, VM_UUID and an authorized migration window.
openstack server migrate --live-migration --host "$TARGET_HOST" --wait "$VM_UUID"

# [OS][RO] Verify actual VM placement and migration outcome.
openstack server show "$VM_UUID" -f yaml
openstack server migration list --server "$VM_UUID"
openstack server list --all-projects --host "$COMPUTE_HOST"
~~~

**Do not reboot or remove the host as part of this generic SOP.** EDPM reboots, node replacement, fencing, Instance HA and co-located Ceph operations need separately reviewed RHOSO release-specific procedures. Continue only when all affected workloads have approved dispositions.

## Restore scheduling and validate

~~~bash
# [OS][CHANGE] Only after maintenance finished and source host tested.
openstack compute service set --enable "$COMPUTE_HOST" nova-compute

# [OS][RO] Confirm service UP/enabled, compute inventories and placement.
openstack compute service list --host "$COMPUTE_HOST"
openstack hypervisor show "$COMPUTE_HOST"
openstack server list --all-projects --host "$COMPUTE_HOST"
~~~

**Validation:** reproduce a permitted instance placement/migration transaction and verify guest reachability, console, attached storage and networking. An enabled/up service status is insufficient alone.

**Rollback:** if a migration fails, stop subsequent migrations; preserve the disabled scheduler state until reviewed. If host health is confirmed but only scheduling disable must be undone, re-enable using the command above under change control. Guest relocation rollback is VM-, storage- and topology-dependent and must be separately specified in the approved change.

Record observed before/after states, VM IDs as secure ticket references, migration errors, owner sign-off and outstanding limitations.