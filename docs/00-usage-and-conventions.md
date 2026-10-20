# Usage and conventions

This material targets **Red Hat OpenStack Services on OpenShift (RHOSO) 18.0.x**.
It is a command catalogue, **not** a shell script to run end-to-end. Individual commands have
execution prerequisites, variable placeholders, and differing operational impacts.

- `[OCP]` — workstation with authenticated `oc`.
- `[OS]` — authenticated `OpenStackClient` pod shell (only after discovery of the correct pod and container).
- `[EDPM]` — approved login to a specific RHEL data-plane host.
- `[CEPH]` — authorized Ceph management environment; not automatically the OpenStackClient pod.
- `[POD]` — selected OpenShift service container after discovering namespace/pod/container.
- `[RO]` — intended read-only inventory or diagnostics.
- `[CHANGE]` — creates or modifies resources. Do not run without change authorization and ownership review.
- `[DELETE]` — removes resources. Verify ownership and dependencies first.
- `[UNVERIFIED]` — example requiring environment-specific syntax/tool availability validation.
- `[INDEX]` — quick navigation entry; source section contains the working context.

Never paste these Markdown reference pages directly into `bash`; shell heredocs,
comments and state-changing operations are intended to be executed **individually**.

## Ownership and safety

Before modifications, identify the authoritative GitOps/Argo CD application, Operator CR,
Helm release or other reconciler controlling the configuration. Avoid direct changes to
reconciled child resources. Confirm target namespace, project, tenant, cloud, host and
resource identifiers. Backups and restore follow Red Hat's release-specific procedures.

## Verification status

- Upstream examples were reviewed against publicly documented patterns when the original
  reference was prepared on 2026-10-20; **not** every command was individually verified.
- `bash -n` checks the standalone health-check's Bash syntax, but **does not validate
  commands against a live RHOSO cluster**.
- No live infrastructure validation, authorization audit, failover or DR test was performed.
- OADP control-plane backup guidance is release-gated in the source reference:
  RHOSO 18.0.21+, OpenShift 4.20+, and OADP 1.5+; confirm current support matrix.
- Optional services, pods, image utilities and APIs may not be present in your deployment.

## Health-check safety

`bash scripts/rhoso-healthcheck.sh` uses authenticated read-only commands and writes
local reports under `rhoso-health-<timestamp>` by default. Local report directories
can contain sensitive topology information; share only after review/redaction.
The script produces `PASS`, `WARN`, `FAIL`, `UNAVAILABLE` and does not perform repairs.
A `PASS` means its **implemented check** passed, not complete transaction validation.

## Original files

The initial unmodified `.txt` deliverables are retained under `source/` for auditability.
The Markdown pages provide easier navigation; the script under `scripts/` is the
maintained runnable entry point in this repository package.