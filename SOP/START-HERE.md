# Engineer start here — RHOSO operational boundaries

!!! warning "Production release status: HOLD"
    These SOPs are DRAFT until the release gate is signed off against the target RHOSO deployment. **L1 engineers must not execute [CHANGE], [DELETE] or unverified commands.**

## First five minutes of an incident

1. Capture the **exact failing tenant/system transaction**, region, UTC incident time, VM/resource/request ID and customer-visible symptom.
2. Identify current versus incident-time state, and first evidence-supported failing service boundary.
3. Run the **read-only discovery commands in the matching SOP** using its indicated [OCP]/[OS]/[EDPM]/[POD]/[CEPH] context.
4. Record **PROVEN HEALTHY, PROVEN BROKEN, INFERENCE, HYPOTHESIS, UNKNOWN**; avoid assigning root cause without proof.
5. Redact evidence, open ticket, and hand off with a clearly named owner and missing evidence.

| Role | Authorized use of these DRAFT references | Stop/escalation |
| --- | --- | --- |
| **L1** | Identity/scope, resource status, logs and read-only API calls subject to approved RBAC | Any state-changing action, unclear scope, credential access, or cross-domain failure → L2 |
| **L2** | Service-specific RCA and change **proposal**; execute only separately approved release-verified SOP | Changes affecting cells, production VMs, networking, databases or storage with missing rollback → L3 |
| **L3 / Architect** | Cross-domain design and risk assessment, approved changes, DR planning and escalation to Red Hat | Any unsupported release, unclear authoritative owner, data-loss possibility → stop/change authority |

## Incident escalation bundle

| Required item | Evidence |
| --- | --- |
| User transaction | Command/API/user workflow, input scope, expected outcome, observed error |
| Correlation | UTC time, region, request ID, VM/port/volume/host reference (secure ticket only) |
| First failure | Short, timestamped, redacted log or API response and generating component |
| Proven healthy/broken | Stage-by-stage validated boundary; unrelated layers excluded |
| Unknown | Specific missing test, unavailable API or permission |
| Ownership | Operator CR/GitOps/Helm authority and owning team |
| Action status | Read-only investigation, proposed change, approval ID, rollback, original-transaction validation |

## Navigation

- [Daily health review](operations/daily-health-check.md) · [VM BUILD/ERROR](incidents/vm-build-failure.md)
- [Compute maintenance](maintenance/compute-host-maintenance.md) · [Backup readiness](recovery/backup-readiness.md)
- [Complete administration command reference](https://github.com/sheejithkv/RHOSO/tree/main/docs) — advanced commands are **not** automatically approved for L1.
- [Compatibility register](COMPATIBILITY.md) · [Release gate](RELEASE-GATE.md)
