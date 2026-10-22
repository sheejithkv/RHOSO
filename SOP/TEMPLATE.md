# SOP-[AREA]-[NNN] · [Exact operational objective]

> [!IMPORTANT]
> **DRAFT — NOT APPROVED FOR PRODUCTION.** Substitute discovered resource names, confirm release-specific support, and obtain change authorization for any mutating command. Never treat this Markdown file as an executable shell script.

| Document control | Value | Document control | Value |
| :--- | :--- | :--- | :--- |
| **SOP ID** | SOP-[AREA]-[NNN] | **Version** | 0.1.0 |
| **Status** | DRAFT | **Type** | Operations / Incident / Maintenance / Recovery |
| **Applies to** | RHOSO 18.x; actual minor/micro release **not yet verified** | **Risk** | Read-only / Approved change / Destructive |
| **Owner** | Unassigned | **Approver** | Unassigned |
| **Last validated** | Not validated on target cluster | **Next review** | Not scheduled |
| **Change / ticket** | Not assigned | **Authoritative source** | Identify Operator CR / GitOps / Helm / other reconciler |

**On this page:** [Purpose](#1-purpose-and-success-criteria) · [Scope](#2-scope-and-exclusions) · [Preconditions](#3-preconditions-and-access) · [Risks](#4-impact-and-stop-conditions) · [Flow](#5-decision-path) · [Procedure](#6-step-by-step-procedure) · [Validation](#7-validation) · [Rollback](#8-rollback-and-recovery) · [Troubleshooting](#9-troubleshooting-and-escalation) · [References](#10-references) · [Revision](#11-revision-history)

## 1. Purpose and success criteria

**Trigger / transaction:** [What exact user/system action prompted this SOP? Identify original request ID/time.]

**Desired outcome:** [Measurable user-visible success; not only API status or pod readiness.]

## 2. Scope and exclusions

**Included:** [service, cell, host, storage/network backend, impacted workloads].

**Not included:** [optional services, untested versions, irreversible repair, etc.].

**Context:** `[OCP]` OpenShift workstation; `[OS]` authenticated OpenStackClient; `[EDPM]` RHEL data plane; `[POD]` discovered service container; `[CEPH]` authorized Ceph environment.

## 3. Preconditions and access

- Confirm `oc whoami`, target cloud, namespace, privileges and relevant Operator/EDPM CRs.
- Discover pod/container and exact service scope before executing a pod command.
- Read credentials from **approved authentication context**; never paste or commit secrets.
- Locate authoritative GitOps source / Operator CR, review approved change and topology constraints.
- Verify RHOSO/OpenShift/EDPM versions and official Red Hat release-specific documentation.

## 4. Impact and stop conditions

> [!CAUTION]
> **STOP** if the impacted transaction is not identified, controller ownership is unknown, required backup/rollback has not been verified, or evidence conflicts. No default restarts, deletion, forced state changes or blind migrations.

| Impact | Risk | Control |
| :--- | :--- | :--- |
| [User/VM/service impact] | [Failure mode] | [Permission, change gate, rollback trigger] |

## 5. Decision path

~~~mermaid
flowchart TD
    A["Capture exact transaction and timestamps"] --> B{"First proven failure known?"}
    B -- "No" --> C["Collect one read-only fault-domain evidence set"]
    C --> B
    B -- "Yes" --> D{"Change necessary?"}
    D -- "No" --> E["Record observed outcome and validate transaction"]
    D -- "Yes" --> F{"Approved, owned and rollback ready?"}
    F -- "No" --> G["STOP and escalate"]
    F -- "Yes" --> H["Apply minimum reviewed change"]
    H --> I["Reproduce original transaction"]
    I --> J{"Acceptance criteria pass?"}
    J -- "No" --> G
    J -- "Yes" --> K["Record evidence and handover"]
~~~

## 6. Step-by-step procedure

| Step | Action / execution context | Expected evidence | Interpretation / next step |
| :--- | :--- | :--- | :--- |
| 1 | **Read-only** · `[OCP]` Discover scope | Actual names and status; no secrets | Stop if multiple candidates not identified |
| 2 | **Read-only** · `[OS]` Inspect transaction | Exact state / request ID | Identify first proven failing boundary |
| 3 | **Change-controlled** · only where approved | Explicit postcondition | Validate original transaction; rollback if pre-agreed condition |

**Step 1 — Discover target (read-only; [OCP])**

~~~bash
oc whoami
oc get openstackcontrolplanes -A
~~~

**Expected:** authenticated identity and discovered namespace; never infer that an existing CR means an API transaction works.

**Step 2 — Reproduce and investigate (read-only; [OS])**

~~~bash
# Execute inside discovered, authenticated OpenStackClient.
openstack token issue
~~~

**Expected:** token issue confirms Keystone authentication only. Validate the original failed operation separately.

**Step 3 — Approved change (if any; [context])**

_No generic remediation. Add site-verified exact commands only after authoritative owner and change approval are recorded._

## 7. Validation

| Check | Acceptance condition | Evidence / time |
| :--- | :--- | :--- |
| Original transaction | [Same request type succeeds end to end] | [Redacted incident reference] |
| Related service impact | [No unexpected regression] | [Monitoring or test reference] |
| Current versus incident-time state | [Differences recorded] | [Time-series reference] |

> [!NOTE]
> A successful `openstack token issue`, pod `Running`, or HTTP 200 response **does not** by itself establish end-to-end application/service health.

## 8. Rollback and recovery

**Rollback owner:** [person/role]. **Trigger:** [specific failed acceptance/stop condition]. **Prerequisites:** [data/backup/host safety]. **Rollback action:** [exact, verified approved steps or "not applicable for read-only SOP"]. **Rollback validation:** rerun the original transaction.

## 9. Troubleshooting and escalation

**PROVEN HEALTHY:** [facts/timestamps]. **PROVEN BROKEN:** [first failing stage + request ID]. **INFERENCE:** [causal interpretation]. **HYPOTHESIS:** [unverified possibilities]. **UNKNOWN:** [missing evidence].

Escalation: [team, incident bridge, ticket]. Provide a *redacted*, timestamped short log excerpt supporting the first failing boundary, not bulk confidential logs.

## 10. References

- [RHOSO 18.0 official documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0)
- [Repository execution contexts](https://github.com/sheejithkv/RHOSO/blob/main/docs/00-usage-and-conventions.md)
- [Worked example](operations/EXAMPLE.md) — replace with the example link for your SOP's category.

## 11. Revision history

| Version | Date (UTC) | Author / reviewer | What changed | Target validation |
| :--- | :--- | :--- | :--- | :--- |
| 0.1.0 | YYYY-MM-DD | Unassigned | Initial draft | Not performed |
