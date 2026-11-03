# RHOSO 18.x operating procedures

!!! danger "Controlled-document status: DRAFT / NO-GO"
    The website is a **public engineering reference**. The SOPs have **not** been validated against a target RHOSO deployment or signed by an authorized approver. Do not treat them as production-approved procedures.

**[L1/L2/L3 start here](START-HERE.md)** · **[Production release gate](RELEASE-GATE.md)** · [Compatibility register](COMPATIBILITY.md)

## Corporate-style controlled SOP catalogue

The four SOPs now follow the same **nine-section document layout** as the supplied corporate example: document information, formal review and approval, revision history, table of contents, purpose, scope, applicability, terms and definitions, roles and responsibilities, implementation, review requirements, references, and appendices.

| Area | Procedure | Worked example | Approval |
| --- | --- | --- | --- |
| Operations | [RHOSO-ITD-SOP-OPS-001 Daily health](operations/daily-health-check.md) | [Example](operations/EXAMPLE.md) | DRAFT |
| Incidents | [RHOSO-ITD-SOP-INC-001 VM BUILD/ERROR](incidents/vm-build-failure.md) | [Example](incidents/EXAMPLE.md) | DRAFT |
| Maintenance | [RHOSO-ITD-SOP-MNT-001 Compute host](maintenance/compute-host-maintenance.md) | [Example](maintenance/EXAMPLE.md) | DRAFT |
| Recovery | [RHOSO-ITD-SOP-REC-001 Backup readiness](recovery/backup-readiness.md) | [Example](recovery/EXAMPLE.md) | DRAFT |

**Print:** Open an SOP in the MkDocs site and use the browser's Print → Save as PDF function. The SOP-only A4 stylesheet applies formal header, dark section bands, grey table headers and clear revision/approval details. Browser printing does not insert or validate legal signatures or formal document-control approval.

**Branding:** The header uses a text-only RHOSO identifier. Replace or supplement it with an approved corporate logo only after the organization grants the appropriate rights. Do not copy the CBUAE logo, confidential legal notice, or organization name from an example.

## Updating or adding an SOP

1. Copy [TEMPLATE.md](TEMPLATE.md) for a new SOP or edit the appropriate existing Markdown on a Git branch.
2. Fill in actual owner, document reference, revision, release applicability, department and approval details; do not invent signatures or dates. Keep as **DRAFT** until verified.
3. Populate **all nine numbered sections**, with commands and expected outcomes in Section 6. Separate [OCP], [OS], [POD] and [EDPM] execution contexts, L1 read-only versus L2/L3 approved actions.
4. Update the linked worked example where necessary; mark fictional outputs **SIMULATED**.
5. Update [CHANGELOG.md](CHANGELOG.md), catalogue and `mkdocs.yml` navigation if creating a new SOP; submit a PR and pass automated checks.
6. Merge to publish the website. **Actual production approval remains a separate release-gate process**, not a GitHub merge.

The Markdown SOPs are the only source of truth. No duplicate Word files or independently maintained HTML viewers are required.

## Further references

- [Contributing / document review policy](CONTRIBUTING.md)
- [Release gate and outstanding validation](RELEASE-GATE.md)
- [RHOSO 21-section command catalogue](https://github.com/sheejithkv/RHOSO/tree/main/docs) — advanced commands are not automatically authorized for L1.
