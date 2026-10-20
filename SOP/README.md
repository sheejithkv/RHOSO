# RHOSO Standard Operating Procedures (SOP)

This directory holds **transaction-oriented operational procedures** for Red Hat OpenStack Services on OpenShift (RHOSO) 18.x. The numbered [command catalogue](../docs/00-usage-and-conventions.md) describes available commands; SOPs describe **when, why, by whom, and how to validate** a particular operation.

**Status:** All starter SOPs are DRAFT examples, not locally approved production procedures. A successful CLI response alone does not establish end-to-end service health.

## Directory map

- [Procedure template](TEMPLATE.md) — copy for a new or revised SOP
- [Contributing and approval workflow](CONTRIBUTING.md) — versioning, evidence, safety and review rules
- [Improvement backlog](IMPROVEMENTS.md) — prioritized, not-yet-implemented enhancements
- [Change log](CHANGELOG.md) — SOP changes and review history
- [Daily RHOSO health check](operations/daily-health-check.md) — read-only operational review
- [VM BUILD/ERROR incident](incidents/vm-build-failure.md) — transaction-first investigation
- [Compute maintenance](maintenance/compute-host-maintenance.md) — change-controlled host scheduling and migration
- [Backup readiness](recovery/backup-readiness.md) — read-only protection verification, not a restore procedure

## Status lifecycle

**DRAFT** -> **REVIEWED** -> **APPROVED** -> **DEPRECATED**

- DRAFT: proposed, untested or incomplete in the target environment.
- REVIEWED: architecture, command syntax, security and rollback reviewed; site validation pending.
- APPROVED: named technical owner and approver accepted a version-specific procedure and recorded evidence from the target environment.
- DEPRECATED: superseded or incompatible; retain history and successor link.

Document state is a human declaration; the repository does not automatically enforce approvals. Store ticket and test evidence **references only**, not credentials, incident payloads, customer identifiers, or unredacted logs.

## Before any production change

1. Capture the original failed or maintenance transaction; identify current versus incident-time observations.
2. Identify the authoritative Operator CR, GitOps/Argo CD application, Helm release, or other controller before editing anything.
3. Mark each evidence item **PROVEN HEALTHY**, **PROVEN BROKEN**, **INFERENCE**, **HYPOTHESIS**, or **UNKNOWN**.
4. Locate the **first proven failure boundary**; do not claim an unproven root cause.
5. Approve a minimal change with blast radius, rollback, stop conditions, and a validation of the **original transaction**.
6. Attach redacted evidence and record the observed result. No default restarts, pod deletion, host reboots, or blind failovers.

## Propose improvements

Open a GitHub issue or pull request with the observed gap, environment/release applicability, supporting evidence, proposed change, risk, test plan and documentation sources. Link it from [IMPROVEMENTS.md](IMPROVEMENTS.md); do not silently edit an approved SOP.

All commands are **illustrative until target-cluster validated**. See [Red Hat sources](../docs/official-sources.md).