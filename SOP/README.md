# RHOSO 18.x · Standard Operating Procedures

> [!IMPORTANT]
> These are **engineer-facing, versioned SOPs**, not a script to execute from top to bottom. The current procedures and worked examples are **DRAFT** and have **not** been approved or tested against a production RHOSO environment. Validate commands against your release, service layout and organizational change process.

## Maintaining and updating SOPs

**[Start here: exact SOP update and release guide](MAINTAINING-SOPS.md)** — edit an existing SOP, add a new one, update examples, synchronize the two styled HTML copies, validate, review and merge. **Markdown and the visual HTML are not automatically synchronized.**

## Visual SOP layout — open the styled version

![SOP visual design overview](visual/sop-preview.svg)

**[Download / open the styled SOP interface](visual/index.html)** · [Viewing instructions and validation](visual/README.md)

> [!NOTE]
> The GitHub file viewer shows HTML **source**. To see the designed interface matching the proposal, download `visual/index.html` using **Raw / Download raw file** and open it locally in your browser. A copy at `docs/sop/index.html` is Pages-ready, but GitHub Pages hosting is not enabled or verified. The SVG above is a schematic preview, not a screenshot of a live RHOSO system.

## Operations library

| Area | Primary operating procedure | Worked engineer example | Purpose |
| :--- | :--- | :--- | :--- |
| **Operations** | [SOP-OPS-001 — Daily health check](operations/daily-health-check.md) | [Example: daily shift verification](operations/EXAMPLE.md) | Discover, run, classify, escalate |
| **Incidents** | [SOP-INC-001 — VM BUILD/ERROR](incidents/vm-build-failure.md) | [Example: Nova scheduler boundary](incidents/EXAMPLE.md) | Follow the request across services |
| **Maintenance** | [SOP-MNT-001 — Compute host](maintenance/compute-host-maintenance.md) | [Example: controlled host drain](maintenance/EXAMPLE.md) | Approve, disable, migrate, verify |
| **Recovery** | [SOP-REC-001 — Backup readiness](recovery/backup-readiness.md) | [Example: review recovery readiness](recovery/EXAMPLE.md) | Check backup evidence; do not assume recoverability |

## Standard authoring system

| Resource | Use |
| :--- | :--- |
| [Maintenance and update instructions](MAINTAINING-SOPS.md) | Exact authoring, visual-sync, testing and PR procedure |
| [SOP template](TEMPLATE.md) | Document-control panel; numbered sections; step/command/expected/interpretation layout |
| [Contribution and approval rules](CONTRIBUTING.md) | Author, review, evidence, release, deprecation |
| [Improvement backlog](IMPROVEMENTS.md) | Prioritized proposed controls and future SOPs |
| [Revision history](CHANGELOG.md) | Audit trail for document changes |
| [Red Hat references](../docs/official-sources.md) | Verify against the target RHOSO release |

### Standard 11-part SOP anatomy

~~~mermaid
flowchart LR
  A["Title + metadata"] --> B["Purpose + scope"]
  B --> C["Access + risk gate"]
  C --> D["Decision path"]
  D --> E["Numbered steps"]
  E --> F["Expected results"]
  F --> G["Validation"]
  G --> H["Rollback + escalation"]
  H --> I["References + revision"]
~~~

Every operational step specifies **execution context**, **read-only or change**, **exact command**, **expected result**, **interpretation**, and **stop/next action**. For incidents, classify **PROVEN HEALTHY / PROVEN BROKEN / INFERENCE / HYPOTHESIS / UNKNOWN** and document the **first proven failure boundary**. For maintenance, identify ownership and authority, impact, stop condition, rollback, and validation of the original transaction.

> [!TIP]
> Start with the [operations worked example](operations/EXAMPLE.md) to see how a realistic filled-in SOP is structured. All sample output is explicitly **SIMULATED**, never presented as live cluster evidence.

**Status lifecycle:** DRAFT → REVIEWED → APPROVED → DEPRECATED. Approval requires an identified owner, target release, evidence and organizational sign-off. Markdown labels alone **do not** enforce an approval workflow. Follow [CONTRIBUTING.md](CONTRIBUTING.md).

Reference library: [21 RHOSO command sections](../docs/00-usage-and-conventions.md).