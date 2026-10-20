# SOP-&lt;AREA&gt;-&lt;NNN&gt;: &lt;Concise title&gt;

| Field | Value |
| --- | --- |
| SOP ID | SOP-&lt;AREA&gt;-&lt;NNN&gt; |
| Status | DRAFT |
| Version | 0.1.0 |
| Owner / approver | &lt;role or nominated owner&gt; / &lt;approver&gt; |
| Target | RHOSO &lt;micro version&gt;, OpenShift &lt;version&gt;, EDPM RHEL &lt;version&gt; |
| Services / optional components | &lt;names; mark absent services not applicable&gt; |
| Last site verification | Not yet validated |
| Approval / change ticket | &lt;link, none while DRAFT&gt; |
| Official reference | &lt;release-specific supported documentation URL&gt; |
| Next review date | &lt;YYYY-MM-DD&gt; |

## Purpose and permitted scope

State the **specific triggering transaction** and expected outcome. Identify tenants, regions, cells, hosts and fault domains **without embedding real identifiers or secrets**.

## Execution context and prerequisites

- [OCP] authenticated OpenShift admin workstation
- [OS] discovered OpenStackClient namespace/pod with approved credentials
- [EDPM] approved RHEL compute node login
- [CEPH] authorized Ceph administration environment
- [POD] discovered service pod + container
- Change window/approvals and RBAC: &lt;required&gt;
- Supported release, deployed components, topology and failover constraints: &lt;check&gt;
- Authoritative reconciler/source of truth: &lt;Operator CR / GitOps repo path / Helm release / other&gt;

## Transaction and evidence boundary

| Category | Incident-time evidence | Current evidence |
| --- | --- | --- |
| PROVEN HEALTHY | &lt;fact + timestamp&gt; | &lt;fact + timestamp&gt; |
| PROVEN BROKEN | &lt;first failing component + log/request ID&gt; | &lt;fact + timestamp&gt; |
| INFERENCE / HYPOTHESIS | &lt;explicitly distinguish&gt; | &lt;explicitly distinguish&gt; |
| UNKNOWN | &lt;missing evidence&gt; | &lt;missing evidence&gt; |

First proven failure: &lt;component, request ID, timestamp, exact response&gt;
Failure mechanism: &lt;fact or unknown&gt;
Trigger / root cause / contributors: &lt;proven or explicitly unknown&gt;

## Read-only discovery and pre-change checks

For each command, state its context and meaningful pass/fail output. Do not assume namespaces or pod names.

~~~bash
# [OCP][READ-ONLY] Confirm OpenShift API identity and deployed RHOSO CR namespaces.
oc whoami
oc get openstackcontrolplanes -A

# [OS][READ-ONLY] Confirm OpenStack token (inside authenticated OpenStackClient).
openstack token issue
~~~

**STOP** if permissions, source-of-truth ownership, topology, prerequisites, or evidence is unclear.

## Authorized change (if applicable)

- Approved change ID: &lt;ticket&gt;
- Authority/source-of-truth and desired-state path: &lt;location&gt;
- Minimum change: &lt;exact command or reviewed diff; not a generic restart&gt;
- Impact/blast radius: &lt;services, tenants, workloads&gt;
- Risk and stop conditions: &lt;list&gt;
- Rollback **preconditions**, steps and owner: &lt;testable sequence&gt;
- Communication/escalation path: &lt;on-call role&gt;

~~~bash
# [CHANGE] Replace with tested commands only after site review.
# No changes are provided in the template.
~~~

## Validation — reproduce the original transaction

- Before/after request ID, test workload, timestamp and client: &lt;redacted references&gt;
- Expected outcome and error budget: &lt;measurable acceptance criteria&gt;
- Check user-visible transaction, not only pod/Operator readiness.
- Test dependencies affected by the change (auth, networking, storage, quota, data path).
- Confirm health at the impacted fault domain; record unresolved risks.

## Rollback and handover

State rollback trigger, validated rollback procedure, validation of the original transaction **after rollback**, on-call ownership, service ticket, and handover. Do not perform unapproved automatic recovery.

## Revisions

| Version | Date | Author/reviewer | Change | Validation reference |
| --- | --- | --- | --- | --- |
| 0.1.0 | &lt;YYYY-MM-DD&gt; | &lt;names/roles&gt; | Draft | Not validated |
