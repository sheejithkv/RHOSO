# RHOSO 18.x operating procedures

!!! danger "NOT YET RELEASED AS PRODUCTION-APPROVED L1 RUNBOOK"
    The documentation website is built and published automatically, but target-site RHOSO execution validation, approvers and release gate are outstanding. **Current status: DRAFT / NO-GO.**

**[Start here — L1/L2/L3 escalation](START-HERE.md)** · **[Production release gate](RELEASE-GATE.md)** · [Compatibility register](COMPATIBILITY.md)

The **Markdown SOPs are the only maintained SOP source**; GitHub Actions generates the MkDocs Material website. No duplicated HTML files.

## Operational SOP catalogue

| Area | Procedure | Worked engineer example | Approval |
| --- | --- | --- | --- |
| Operations | [SOP-OPS-001 Daily health](operations/daily-health-check.md) | [Simulated example](operations/EXAMPLE.md) | DRAFT |
| Incidents | [SOP-INC-001 VM BUILD/ERROR](incidents/vm-build-failure.md) | [Simulated example](incidents/EXAMPLE.md) | DRAFT |
| Maintenance | [SOP-MNT-001 Compute host](maintenance/compute-host-maintenance.md) | [Simulated example](maintenance/EXAMPLE.md) | DRAFT |
| Recovery | [SOP-REC-001 Backup readiness](recovery/backup-readiness.md) | [Simulated example](recovery/EXAMPLE.md) | DRAFT |

## Updating a procedure

1. Copy [TEMPLATE.md](TEMPLATE.md) for new SOPs or edit the existing Markdown file on a branch.
2. Include real execution context, expected output, first failure, L1/L2/L3 boundary, validation and rollback; cite official release-specific docs.
3. Update associated **EXAMPLE.md** if necessary and clearly label fictional output SIMULATED.
4. Record the change in [CHANGELOG.md](CHANGELOG.md), catalogue, and `mkdocs.yml` navigation for new SOPs.
5. Submit a PR. CI builds MkDocs and tests the script with mock inputs. Obtain technical review.
6. Merge only to publish documentation; production approval requires the separate [release gate](RELEASE-GATE.md).

## Further references

- [RHOSO 21-section administration command reference](https://github.com/sheejithkv/RHOSO/tree/main/docs) — contains **advanced state-changing commands**; not auto-authorized for L1.
- [Contributing/approval](CONTRIBUTING.md) · [Improvement backlog](IMPROVEMENTS.md) · [Revision log](CHANGELOG.md)
